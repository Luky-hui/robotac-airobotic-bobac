#!/usr/bin/env python3
import math, cv2, numpy as np, rospy
from cv_bridge import CvBridge
from sensor_msgs.msg import Image, CameraInfo

class D:
    def __init__(self):
        rospy.init_node('bobac_black_pen_live_depth', anonymous=True)
        self.b=CvBridge(); self.rgb=None; self.dep=None; self.info=None
        rospy.Subscriber('/bobac3_arm/rgb/rgb_raw', Image, self.rgb_cb, queue_size=1)
        rospy.Subscriber('/bobac3_arm/depth/depth_raw', Image, self.dep_cb, queue_size=1)
        rospy.Subscriber('/bobac3_arm/depth/camera_info', CameraInfo, self.info_cb, queue_size=1)
        rospy.Subscriber('/bobac3_arm/rgb/camera_info', CameraInfo, self.info_cb, queue_size=1)
    def rgb_cb(self,m): self.rgb=self.b.imgmsg_to_cv2(m,'bgr8')
    def dep_cb(self,m): self.dep=np.array(self.b.imgmsg_to_cv2(m,'passthrough'))
    def info_cb(self,m): self.info=m
    def depth_m(self,u,v):
        if self.dep is None: return None
        h,w=self.dep.shape[:2]; p=self.dep[max(0,v-4):min(h,v+5),max(0,u-4):min(w,u+5)].astype(np.float32)
        vals=p[np.isfinite(p)&(p>0)]
        if vals.size==0: return None
        z=float(np.median(vals)); return z/1000.0 if z>20 else z
    def detect(self,img):
        h,w=img.shape[:2]; gray=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
        dark=cv2.inRange(gray,0,75); dark=cv2.morphologyEx(dark,cv2.MORPH_OPEN,np.ones((3,3),np.uint8),iterations=1)
        cs,_=cv2.findContours(dark,cv2.RETR_EXTERNAL,cv2.CHAIN_APPROX_SIMPLE)
        best=None
        for c in cs:
            area=cv2.contourArea(c); x,y,bw,bh=cv2.boundingRect(c)
            if area<120 or area>8000 or bw<20 or bh<3: continue
            asp=max(bw/max(1.0,bh), bh/max(1.0,bw))
            if asp<3 or x<5 or y<5 or x+bw>w-5 or y+bh>h-5: continue
            pad=35; roi=img[max(0,y-pad):min(h,y+bh+pad),max(0,x-pad):min(w,x+bw+pad)]
            white=cv2.inRange(cv2.cvtColor(roi,cv2.COLOR_BGR2HSV),(0,0,145),(179,80,255))
            wf=float(np.count_nonzero(white))/max(1,white.size)
            if wf<0.35: continue
            rect=cv2.minAreaRect(c); (cx,cy),(rw,rh),ang=rect; axis=ang if rw>=rh else ang+90
            score=area*asp*(0.5+wf)
            if best is None or score>best[0]: best=(score,(x,y,x+bw,y+bh),(int(cx),int(cy)),area,asp,axis,wf)
        return best
    def run(self):
        r=rospy.Rate(15); last=rospy.Time(0)
        while not rospy.is_shutdown():
            if self.rgb is None: r.sleep(); continue
            img=self.rgb.copy(); det=self.detect(img); lines=[]
            if det:
                _,box,(u,v),area,asp,ang,wf=det; x0,y0,x1,y1=box; z=self.depth_m(u,v); xyz='depth=--'
                if z is not None and self.info is not None:
                    fx,fy,cx,cy=self.info.K[0],self.info.K[4],self.info.K[2],self.info.K[5]
                    X=(u-cx)*z/fx; Y=(v-cy)*z/fy; xyz='camXYZ=(%.3f,%.3f,%.3f)m'%(X,Y,z)
                elif z is not None:
                    xyz='depth=%.3fm'%z
                cv2.rectangle(img,(x0,y0),(x1,y1),(0,255,0),2); cv2.circle(img,(u,v),4,(0,0,255),-1)
                lines=['PEN_DETECT_OK=True bbox=(%d,%d)-(%d,%d)'%(x0,y0,x1,y1),'center=(%d,%d) angle=%.1fdeg'%(u,v,ang),xyz,'area=%.0f aspect=%.2f white=%.2f'%(area,asp,wf)]
            else: lines=['PEN_DETECT_OK=False']
            y=24
            for s in lines:
                cv2.putText(img,s,(10,y),cv2.FONT_HERSHEY_SIMPLEX,0.58,(0,0,0),3); cv2.putText(img,s,(10,y),cv2.FONT_HERSHEY_SIMPLEX,0.58,(255,255,255),1); y+=24
            cv2.imshow('Bobac black pen recognition + depth',img)
            if (cv2.waitKey(1)&255) in (27,ord('q')): break
            if (rospy.Time.now()-last).to_sec()>1:
                print(' | '.join(lines), flush=True); last=rospy.Time.now()
            r.sleep()
        cv2.destroyAllWindows()
D().run()

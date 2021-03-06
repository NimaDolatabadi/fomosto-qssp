      subroutine qpspropg0(ypsv,lyup,lylw)
      implicit none
c
c     calculation of response (with gravity) to psv source (l=0)
c     ypsv(6,4): solution vector (complex)
c
      integer lyup,lylw
      double complex ypsv(6,4)
c
      include 'qpglobal.h'
c
c     work space
c
      integer i,istp,ly,key
      double complex y0(3),yup(3),ylw(3),coef(2,2),b(2,2)
      external qpdifmat0
c
c===============================================================================
c
c     propagation from surface to source
c
      yup(1)=(1.d0,0.d0)
      yup(2)=(0.d0,0.d0)
      yup(3)=(0.d0,0.d0)
c
      if(lyr.eq.lyup)call cmemcpy(yup,y0,3)
c
      do ly=lyup,lys-1
        call ruku(yup,3,1,ly,0,qpdifmat0,rrup(ly),rrlw(ly))
        if(ly.eq.lyr-1)call cmemcpy(yup,y0,3)
      enddo
      yup(1)=yup(1)/crrup(lys)
      yup(2)=yup(2)/crrup(lys)**2
c     yup(3)=yup(3)
c
c===============================================================================
c
c     propagation from bottom to source
c
      call qpstart0(lylw,ylw)
      if(lylw.eq.lyr.and.lylw.gt.lys)call cmemcpy(ylw,y0,3)
c
      do ly=lylw-1,lys,-1
        call ruku(ylw,3,1,ly,0,qpdifmat0,rrlw(ly),rrup(ly))
        if(ly.eq.lyr.and.ly.gt.lys)call cmemcpy(ylw,y0,3)
      enddo
      ylw(1)=ylw(1)/crrup(lys)
      ylw(2)=ylw(2)/crrup(lys)**2
c     ylw(3)=ylw(3)
c
      y0(1)=y0(1)/crrup(lyr)
      y0(2)=y0(2)/crrup(lyr)**2
c     y0(3)=y0(3)
c
c===============================================================================
c     source function
c===============================================================================
c
      b(1,1)=(1.d0,0.d0)
      b(2,1)=(0.d0,0.d0)
      b(1,2)=(0.d0,0.d0)
      b(2,2)=(1.d0,0.d0)
      do i=1,2
        coef(i,1)=yup(i)
        coef(i,2)=-ylw(i)
      enddo
      key=0
      call cdsvd500(coef,b,2,2,0.d0,key)
      if(key.eq.0)then
        print *,' Warning in qpspropg0: anormal exit from cdgemp!'
        return
      endif
      if(lyr.le.lys)then
        do istp=1,2
          do i=1,2
            ypsv(i,istp)=b(1,istp)*y0(i)
          enddo
          ypsv(5,istp)=b(1,istp)*y0(3)
          ypsv(6,istp)=ypsv(5,istp)/crrup(lyr)
        enddo
      else
        do istp=1,2
          do i=1,2
            ypsv(i,istp)=b(2,istp)*y0(i)
          enddo
          ypsv(5,istp)=b(2,istp)*(y0(3)-ylw(3))+b(1,istp)*yup(3)
          ypsv(6,istp)=ypsv(5,istp)/crrup(lyr)
        enddo
      endif
      return
      end

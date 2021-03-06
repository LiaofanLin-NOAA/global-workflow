       subroutine stal
       common/pshift/ishiftx(50),ishifty(50),ishiftxx,ishiftyy
       character*2 c2
       character*1 cv
       character*9 cloc
       dimension kp(2)
c       call fonts
        rewind(39)
        print*,'Entered stal after rewind 39'
       do 899,k=1,999999
      read(39,891,end=9899)
     1 ipx,ipy,item,idew,ipres,itend,idd,iss,icover,iwx,
     1 itrace,icloud,cloc
       print*,'ipx,ipy,item,idew,ipres,itend,idd,iss,icover,iwx,
     1         itrace,icloud,cloc =  ',
     2   ipx,ipy,item,idew,ipres,itend,idd,iss,icover,iwx,
     3   itrace,icloud,cloc
      ipx=ipx+ishiftxx
      ipy=ipy+ishiftyy
      dew=idew
      pres=ipres
      temp=item
      speed=iss
       dir=idd
      tend=itend
      cover=icover
      ht=11.
       call staplt(ipx,ipy,ht,temp,dew,pres,tend,dir,speed,cover,iwx,
     1 itrace,icloud,cloc(3:7))
 899   continue
 891   format(16x,9i5,3i5,a9)
 9899  continue
ckumar       rewind (89)
       rewind (39)
       return
       end
        subroutine staplt
     1 (ix,iy,font,temp,dew,pres,tend,dir,speed,cover,iwx,itrace,
     1  icloud,cloc)
        dimension ifont(0:99),icharr(0:99)
        character*3 c3
        character*5  cloc
c    ifont and icharr specify the font number and character
c    for each WMO current weather number from 1 to 99.  The
c    weather number is the array index.  For example if the current
c    weather is 04, then the font number is 35, and the character
c    is 'Z41' (integer 65)  This is a  "smoke" symbol
        data ifont/
     1 00,00,00,00,35,35,34,34,34,34,
     1 33,33,33,33,33,33,33,33,33,33,
     2 33,33,33,33,33,33,33,33,33,
     3 33,33,33,33,33,33,33,33,33,33,33,
     4 35,33,33,33,33,33,33,33,33,33,
     5 33,33,34,34,34,34,35,35,33,33,
     6 33,33,33,33,34,34,35,35,34,34,
     7 32,34,35,36,36,36,35,35,35,33,
     8 34,34,34,34,34,34,34,34,34,34,
     9 34,36,36,36,36,36,36,36,36,36/
       data icharr /
     1 00,00,00,00,65,66,65,66,67,04,
     1 48,65,66,68,69,70,71,72,73,74,
     2 75,76,77,78,79,80,81,82,83,
     3 84,85,85,85,85,85,86,87,88,89,89,
     4 71,48,49,50,51,52,53,54,48,48,
     5 55,56,68,69,71,70,73,74,57,57,
     6 45,47,43,41,72,73,75,76,74,74,
     7 72,75,77,68,68,69,78,78,78,44,
     8 80,81,82,83,84,85,86,87,88,89,
     9 89,71,72,73,74,75,76,77,78,79/
        character*3 ctemp,cdew,ctend
        character*4 cdir,cpres
        character*1 cv
        dimension kp(2)
        character*2 c2
        ix=ix+4+64
        c2='90'
        kp(1)=0
        kp(2)=0
        print*,'temp,pres,dew,tend,cover,dir ',temp,pres,dew,
     &  tend,cover,dir
        if ((temp .lt. -99) .or. (temp . gt. 999)) then
           ctemp = " "
        else 
           write(ctemp,101)ifix(temp)
        end if
        print*,'In sta.f ctemp & temp ',ctemp,temp
        if ((pres .lt. -99) .or. (pres . gt. 999)) then
           cpres = " "
        else
           write(cpres,1011)ifix(pres)
        end if
        print*,'In sta.f cpres & pres ',cpres,pres
        if ((dew .lt. -99) .or. (dew . gt. 999)) then
           cdew = " "
        else
           write(cdew,101)ifix(dew)
        end if
        print*,'In sta.f cdew & dew ',cdew,dew
        if ((tend .lt. -99) .or. (tend . gt. 999)) then
           ctend = " "
        else
           write(ctend,101)ifix(tend)
        end if
        print*,'In sta.f ctend & tend ',ctend,tend
        itend=tend
        icover=cover
c        write(cdir,101) ifix(dir)
c        print*,'In sta.f cdir & dir ',cdir,dir
c        c2=cdir(1:2)
        isp=speed
        idir=dir
        print*,'In sta.f isp & idir ',isp,idir
 101    format(i3)
 1011    format(i3.3)
         font=1.0
       kp(1)=1
c  TEMPERATURE
         kp(2)=2
       if(temp .gt. -9.) then 
       call PUTLAB (ix-12,iy-20,font,ctemp(2:3),90.0,2,kp,0)
       else
       call PUTLAB (ix-12,iy-30,font,ctemp,90.0,3,kp,0)
       endif
c   PRESSURE
       call PUTLAB (ix-11,iy+14,font,cpres,90.0,3,kp,0)
c   DEWPOINT
       ixd=ix+17
       if(iwx .lt. 4 .or. iwx .gt. 99) ixd=ix+2
        if (dew .gt. -9.) then
       call PUTLAB (ixd,iy-20,font,cdew(2:3),90.0,2,kp,0)
       else
       call PUTLAB (ixd,iy-30,font,cdew,90.0,3,kp,0)
       endif
       kp(2)=0
c      STATION NAME 
        call putlab(ixd+14,iy-30,4.0,cloc,90.0,5,kp,0)
c   PRESSURE TENDANCY 
       if (itrace .ge. 0 .and. itrace .lt. 9) then
       sfont=4.
       call PUTLAB (ix+4,iy+16,font,ctend(2:3),90.0,2,kp,0)
       else
       if(itend .lt. 10 .and. itend .gt. -10) then
       call PUTLAB (ix+4,iy+16,font,ctend(2:3),90.0,2,kp,0)
       else
       call PUTLAB (ix+4,iy+16,font,ctend(1:3),90.0,3,kp,0)
       endif
       endif 
c    CURRENT WEATHER DEPICTION
       kp(1)=0
        cv=char(65)
       if(iwx .gt. 0 .and. iwx .lt. 100) then
       fnn=ifont(iwx)
       cv=char(icharr(iwx))
       call putlab(ix,iy-18,fnn,cv,90.0,1,kp,0)
        endif
c    BAROGRAPH TRACE 
       if (itrace .lt. 9 .and. itrace .ge. 0) then
        cv=char(64+itrace)
        call putlab(ix+10,iy+34,31.,cv,90.0,1,kp,0)
        endif
c    LOW MIDDLE AND HIGH CLOUDS
       if(icloud .gt. 0 .and. icloud .lt. 1000) then
       write(c3,103)icloud
       read(c3,1033)icl,icm,ich
 103   format(i3)
 1033  format(3i1)
       cv=char(65+icl)
        call putlab(ix+15,iy,28.,cv,90.0,1,kp,0)
       cv=char(65+icm)
        call putlab(ix-10,iy,29.,cv,90.0,1,kp,0)
       cv=char(65+ich)
        call putlab(ix-20,iy,30.,cv,90.0,1,kp,0)
       endif
c   WIND SPEED AND DIRECTION BARB.  PLOT CIRCLE FOR ZERO SPEED
c   plot staff on circle boundary rather than center.
c   
      d2r=3.1415927/180.
      csize=6.
      dir=idir
      if(dir .lt. 0) dir=-dir
      xd=csize*sin(dir*d2r)
      yd=csize*cos(dir*d2r)
      ixw=ix+xd+7
      iyw=iy+yd+7
       if(idir .gt. -361 .and. isp .ge.0 .and.isp .lt. 800) then 
      if(isp .gt. 0)
     1        CALL WNDBRK( ixw,iyw,idir/10,isp,nw,0,iret)
c     1        CALL WNDBRK( ix+6,iy+6,idir/10,isp,nw,0,iret)
       cv=char(67) 
c       kp(1)=3
       kp(2)=4
       if(isp .eq. 0)  call putlab(ix-2,iy-2,37.,cv,90.0,1,kp,0)
       endif
       kp(1)=0 
       kp(2)=2
c   SKY COVER
c       CV='M'
       CV='K'
       if(icover .eq. 1) CV='B'
       if(icover .eq. 2) CV='C'
       if(icover .eq. 3) CV='D'
       if(icover .eq. 4) CV='E'
       if(icover .eq. 5) CV='F'
       if(icover .eq. 6) CV='G'
       if(icover .eq. 7) CV='H'
       if(icover .eq. 8) CV='I'
       if(icover .eq. 9) CV='J'
       if(icover .eq. 0) CV='A'
c  other values of sky cover result in circle with inscribed M plotted
c  to indicate missing sky cover.
c        kp(2)=4
       call putlab(ix,iy,27.,cv,0.0,1,kp,0)
       kp(2)=0
       kp(1)=1
       return
       end

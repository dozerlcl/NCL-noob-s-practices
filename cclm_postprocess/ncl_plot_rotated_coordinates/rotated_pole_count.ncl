;--- 2020.9.7 yycheng 
;--- 目标:CCLM选定区域的可视化，给出一些选取区域的参数，将所选区域在xx投影上绘制出来
;---    所参考的namelist ： LMGRID
;---    input:
;---    在开头输入LMGRID的namelist设置方式
;---    在 mpprojection 选择绘制网格的投影方式
;---    一个典型的案例:

;---  remains:
;---    可以考虑不同fill_value的输出方式，将网格进行填色处理
;------------------------------------------------------------
; &LMGRID
;   startlat_tot  = -24.09, startlon_tot  = -25.13,
;   pollat = 39.25, pollon = -162.0, 
;   dlon=0.44, dlat=0.44, 
;   ie_tot=101, je_tot=111, ke_tot=40
;------------------------------------------------------------
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"


;------------------------------------------------------------
;-- set LMGRID namelists
;------------------------------------------------------------
;  下面是sp包中进行测试的参数
; startlat_tot = -24.09
; startlon_tot = -25.13
; pollat       = 39.25
; pollon       = -162.0
; dlon         = 0.44
; dlat         = 0.44
; ie_tot       = 101
; je_tot       = 111
; ke_tot       = 40
;  进行高原模拟选定的Domain1的区域所在的参数
startlat_tot = -27.3668475
startlon_tot = -14.0084726
pollat       = 32.5  ;  选为模式区域中央？
pollon       = 92.5  ;
dlon         = 0.25
dlat         = 0.25
ie_tot       = 241
je_tot       = 121
ke_tot       = 40
;------------------------------------------------------------
;-- set global constants
;------------------------------------------------------------
pi       =  4.0*atan(1.)
deg2rad  =  pi/180.
rad2deg  =  45./atan(1.)
fillval  = -99999.9

;------------------------------------------------------------
;-- Function:      unrot_lon(rotlat,rotlon,pollat,pollon)
;-- Description:   transform rotated longitude to longitude
;------------------------------------------------------------
undef("unrot_lon")
function unrot_lon( rotlat:numeric, rotlon:numeric, pollat[1]:numeric, pollon[1]:numeric )
local rotlat, rotlon, nrlat, nrlon, nrlat_rank, nrlon_rank, pollon, pollat, \
      lon, s1, c1, s2, c2, rlo, rla, i, tmp1, tmp2
begin
  lon = fillval
  lon@_FillValue = fillval
  
  nrlat      = dimsizes(rotlat)
  nrlon      = dimsizes(rotlon)
  nrlat_rank = dimsizes(nrlat)
  nrlon_rank = dimsizes(nrlon)

  if (any(nrlat .ne. nrlon) .and. (nrlat_rank.ne.1 .or. nrlon_rank.ne.1)) then
      print("Function unrot_lon: unrot_lon:  rotlat and rotlon dimensions do not match")
    return(lon)
  end if
  
  if (nrlat_rank.eq.1 .and. nrlon_rank.eq.1) then
    rla = conform_dims((/nrlat,nrlon/),rotlat,0)    ;-- create 2D latitude array
    rlo = conform_dims((/nrlat,nrlon/),rotlon,1)    ;-- create 2D longitude array
  else
    rla = rotlat
    rlo = rotlon
  end if
  
  rla = rla*deg2rad                                 ;-- convert from degree to radians
  rlo = rlo*deg2rad                                 ;-- convert from degree to radians
    
  lon := (/rlo/)                                    ;-- reassign lon
  lon@_FillValue=fillval
  
  s1   = sin(pollat*deg2rad)
  c1   = cos(pollat*deg2rad)
  s2   = sin(pollon*deg2rad)
  c2   = cos(pollon*deg2rad)
  
  tmp1 = s2*(-s1*cos(rlo)*cos(rla)+c1*sin(rla))-c2*sin(rlo)*cos(rla)
  tmp2 = c2*(-s1*cos(rlo)*cos(rla)+c1*sin(rla))+s2*sin(rlo)*cos(rla)
  
  lon  = atan(tmp1/tmp2)*rad2deg

  lon@units = "degrees_east"
  print("Function unrot_lon: min/max     "+sprintf("%8.4f", min(lon(0,:)))+\
        "  "+sprintf("%8.4f", max(lon(0,:))))
  
  delete([/rlo,rlo,c1,s1,c2,s2,tmp1,tmp2/])
  
  return(lon)
end

;------------------------------------------------------------
;-- Function:      unrot_lat(rotlat,rotlon,pollat,pollon)
;-- Description:   transform rotated latitude to latitude
;------------------------------------------------------------
undef("unrot_lat")
function unrot_lat( rotlat:numeric, rotlon:numeric, pollat[1]:numeric, pollon[1]:numeric )
local rotlat, rotlon, nrlat, nrlon, nrlat_rank, nrlon_rank, pollon, pollat, \
      lat, s1, c1, rlo, rla, i
begin
  lat = fillval
  lat@_FillValue = fillval
  
  nrlat      = dimsizes(rotlat)
  nrlon      = dimsizes(rotlon)
  nrlat_rank = dimsizes(nrlat)
  nrlon_rank = dimsizes(nrlon)

  if (any(nrlat .ne. nrlon) .and. (nrlat_rank.ne.1 .or. nrlon_rank.ne.1)) then
    print("Function unrot_lat:  rotlat and rotlon dimensions do not match")
    return(lat)
  end if
  
  if (nrlat_rank.eq.1 .and. nrlon_rank.eq.1) then
    rla = conform_dims((/nrlat,nrlon/),rotlat,0)    ;-- create 2D latitude array
    rlo = conform_dims((/nrlat,nrlon/),rotlon,1)    ;-- create 2D longitude array
  else
    rla = rotlat
    rlo = rotlon
  end if
  
  rla = rla*deg2rad                                 ;-- convert from degree to radians
  rlo = rlo*deg2rad                                 ;-- convert from degree to radians
  
  lat := (/rla/)                                    ;-- reassign lat
  lat@_FillValue=fillval

  s1  = sin(pollat*deg2rad)
  c1  = cos(pollat*deg2rad)
  
  lat = s1*sin(rla)+c1*cos(rla)*cos(rlo)
  lat = asin(lat)*rad2deg
  
  lat@units = "degrees_north"
  print("Function unrot_lat: min/max     "+sprintf("%8.4f", min(lat(:,0)))+\
        "  "+sprintf("%8.4f", max(lat(:,0))))
  
  delete([/rlo,rla,c1,s1/])
  
  return(lat)
end

begin
    ; file_path = "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/"
    ; file_name = "cptp_test2_0911.nc"
    ; f_ordata = addfile(file_path + file_name, "r")
    ; var     =  f_ordata->FR_LAKE                                      ;-- define variable
    ; rlat_real    =  f_ordata->rlat                                    ;-- get 2D latitude array
    ; rlon_real    =  f_ordata->rlon                                    ;-- get 2D longitude array
    ; pollon_real  =  f_ordata->rotated_pole@grid_north_pole_longitude  ;-- rotated pole longitude
    ; pollat_real  =  f_ordata->rotated_pole@grid_north_pole_latitude   ;-- rotated pole latitude
    ; ;  进行替换，使用读入的数据进行绘制
    ; ie_tot = dimsizes(rlon_real)
    ; je_tot = dimsizes(rlat_real)
    ;--- check ---
    ; print(rlat-rlat_real)
;--- unrotated grid points && setting domains---
    ; lon2d lat x lon
    rlon = fspan(startlon_tot, startlon_tot + (ie_tot-1)*dlon, ie_tot)
    rlat = fspan(startlat_tot, startlat_tot + (je_tot-1)*dlat, je_tot)
    lon2d      =  unrot_lon(rlat, rlon, pollat, pollon)
    lat2d      =  unrot_lat(rlat, rlon, pollat, pollon)
    printMinMax(lon2d, 1)
    printMinMax(lat2d, 1)

end
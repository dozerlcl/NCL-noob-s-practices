;  9.05 参考DKRZ官网给出的rotated pole的绘制方法，改出的脚本
;  与ncl_test_out01.ncl作用相似，只是转变为常见的经纬度坐标格点之后进行绘制
;  参考网站:
;       https://www.dkrz.de/up/services/analysis/visualization/sw/ncl/examples/source_code/dkrz-ncl-remo-plot-rotated-data-example


; remark: 包含将rlat rlon转换为原始经纬度坐标的外部函数，可以进行load


; ------------------------------------------------------------
;-- DKRZ NCL example:      NCL_plot_rotated_grid_REMO.ncl
;--
;-- Description:  plot rotated data on origin grid
;--
;--             - data on a rotated grid
;--             - plot on origin grid
;--             - projection: Orthographic
;--
;-- 14.03.16  meier-fleischer(at)dkrz.de
;------------------------------------------------------------
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

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

;----------------
;--  MAIN
;----------------
begin
;-- open file and read variables
; "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/cptp_test2_0911.nc"
  file_path = "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/"
    file_name = "cptp_test2_0911.nc"
  f_ordata = addfile(file_path + file_name, "r")
  var     =  f_ordata->ALB_DRY                                 ;-- define variable
  rlat    =  f_ordata->rlat                                    ;-- get 2D latitude array
  rlon    =  f_ordata->rlon                                    ;-- get 2D longitude array
  pollon  =  f_ordata->rotated_pole@grid_north_pole_longitude  ;-- rotated pole longitude
  pollat  =  f_ordata->rotated_pole@grid_north_pole_latitude   ;-- rotated pole latitude

;-- unrotate the grid and set 2D lat/lons
  lon2d      =  unrot_lon(rlat, rlon, pollat, pollon)
  lat2d      =  unrot_lat(rlat, rlon, pollat, pollon)

  ;  二维非规则网格的绘制，属性变量规定是一维数组，但是会自动ndtooned
  ; var@lat2d  =  ndtooned(lat2d)                                    ;-- 2D latitudes
  ; var@lon2d  =  ndtooned(lon2d)                                    ;-- 2D longitudes
  var@lat2d = lat2d
  var@lon2d = lon2d
;-- check data

  ; printVarSummary(lat2d)
  ; printVarSummary(lon2d)
  ; printVarSummary(var)
  ; printMinMax(lat2d, 1)
  ; printMinMax(lon2d, 1)   
;-- calculate the min and max lat/lons for the map plot
  minlat  =  min(lat2d)                                 ;-- retrieve minimum latitude value
  minlon  =  min(lon2d)                                 ;-- retrieve maximum latitude value
  maxlat  =  max(lat2d)                                 ;-- retrieve minimum longitude value
  maxlon  =  max(lon2d)                                 ;-- retrieve maximum longitude value
   
;-- open a workstation
  wtype           = "png"                             ;-- plot output type
  wtype@wkWidth   =  1024                             ;-- set workstation width in pixel
  wtype@wkHeight  =  1024                             ;-- set workstation height in pixel
  wks = gsn_open_wks(wtype,"./output_pic_out1/plot_rotated_grid_DKRZ")

;-- set resources
  res                       =  True
  res@gsnAddCyclic          =  False                   ;-- data are not global, don't add lon cyclic point
  res@gsnMaximize           =  True
  ;;;error:导致错误的原因就是下一句地图的选取
  ; res@mpDataBaseVersion     = "HighRes"                ;-- choose map database
  res@mpGridAndLimbOn       =  True                    ;-- turn on grid lines
  res@mpProjection          = "Orthographic"           ;-- change projection
  res@mpCenterLatF          =  minlat + (maxlat -minlat)/2 ;-- center point of view latitude
  res@mpCenterLonF          =  minlon + (maxlon -minlon)/2 ;-- center point of view longitude
  res@mpLimitMode           = "LatLon"                 ;-- map limits mode
  res@mpMinLatF             =  minlat - 0.5            ;-- set min lat
  res@mpMaxLatF             =  maxlat + 0.5            ;-- set max lat
  res@mpMinLonF             =  minlon - 1.             ;-- set min lon
  res@mpMaxLonF             =  maxlon + 1.             ;-- set max lon
  res@mpPerimOn             =  False                   ;-- don't draw the box around the plot

  res@cnFillOn              =  True                    ;-- turn on contour fill
  res@cnLinesOn             =  False                   ;-- don't draw contour lines
  res@cnFillPalette         = "BlueYellowRed"          ;-- choose color map

  res@pmTickMarkDisplayMode = "Always"                 ;-- draw nicer tickmarks

  res@lbBoxMinorExtentF     =  0.2                     ;-- decrease height of labelbar boxes

  res@tiMainString          = "CCLM:  plot rotated grid"  ;-- title
  res@tiMainOffsetYF        = -0.01                   ;-- move title downward

  plot = gsn_csm_contour_map(wks,var(:,:),res)     ;-- draw plot
  
end
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
; startlat_tot = -35.7001388
; startlon_tot = -33.313786
; pollat       = 32.5  ;  选为模式区域中央？
; pollon       = 272.5 ;  180 + 92.5
; dlon         = 0.25
; dlat         = 0.25
; ie_tot       = 241
; je_tot       = 121
; ke_tot       = 40
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

;--- main ---
begin

    ; --- add attributes
    ; -----------------------------------------
    ; ---example
    ; -----------------------------------------
    ;  standard_name :       grid_longitude
    ;  long_name :   rotated longitude
    ;  units :       degrees

    ;  standard_name :       grid_latitude
    ;  long_name :   rotated latitude
    ;  units :       degrees
    ; -----------------------------------------

    ; rlon = fspan(startlon_tot, startlon_tot + (ie_tot-1)*dlon, ie_tot)
    ; rlat = fspan(startlat_tot, startlat_tot + (je_tot-1)*dlat, je_tot)

    ; rlon@standard_name = "grid_longitude"
    ; rlon@long_names    = "rotated longitude"
    ; rlon@units         = "degrees"

    ; rlat@standard_name = "grid_latitude"
    ; rlat@long_names    = "rotated latitude"
    ; rlat@units         = "degrees"


    ; --- input a real domains for checking data
    file_path = "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/cptp_ext_test/"     ;   最好使用绝对路径，相对路径需要在终端中先一步CD到工作区
    file_name = "cptp_08_domain2020091813129.nc"
    ; file_path = "/HGST_SATA_8T_3/yycheng/CCLM_starter_test/cclm-sp-v3.1.1/data/ext/"
    ; file_name = "cptp_test3_0911.nc"
    f_ordata = addfile(file_path + file_name, "r")
    var     =  f_ordata->FR_LAKE                                       ;-- define variable
    rlat_real    =  f_ordata->rlat                                    ;-- get 2D latitude array
    rlon_real    =  f_ordata->rlon                                    ;-- get 2D longitude array
    pollon_real  =  f_ordata->rotated_pole@grid_north_pole_longitude  ;-- rotated pole longitude
    pollat_real  =  f_ordata->rotated_pole@grid_north_pole_latitude   ;-- rotated pole latitude
    ;  进行替换，使用读入的数据进行绘制
    rlat = rlat_real
    rlon = rlon_real
    pollat = pollat_real
    pollon = pollon_real
    je_tot = dimsizes(rlat)
    ie_tot = dimsizes(rlon)
    ;--- check ---
    ; printVarSummary(rlon)
    ; print(rlon)
    ; print(rlat-rlat_real)
    ; print(rlon-rlon_real)
;--- unrotated grid points && setting domains---
    ; lon2d lat x lon
    lon2d      =  unrot_lon(rlat, rlon, pollat, pollon)
    lat2d      =  unrot_lat(rlat, rlon, pollat, pollon)
    domains    =  new((/je_tot,ie_tot/), float)
    domains    =  0
    ; printVarSummary(domains)
    lon2d = where(lon2d<0,lon2d+180.,lon2d)
    print("check lon2d's range")
    printMinMax(lon2d, 1)
    ; print(lon2d)
    
    ; where(condtnl_expr, true_value, false_value)
    domains@lat2d = lat2d
    domains@lon2d = lon2d

    wks = gsn_open_wks("png","./pic_ncloutput/cptp_mapgrid") ; send graphics to PNG file
;--- plot native plot---
;---Set up some contour resources.
  res                       = True
  res@gsnMaximize           = True
  res@gsnDraw               = False   ; Don't draw plot
  res@gsnFrame              = False   ; Don't advance frame.

  res@gsnAddCyclic          = False
;   res@gsnLeftString         = "temperature"
  res@cnFillOn              = True
  res@cnFillPalette         = "temp1" ; set color map
  res@cnLinesOn             = False
  res@cnInfoLabelOn         = False
  res@mpFillOn              = False 
  ; res@mpProjection          = "LambertEqualArea"
  res@mpGridAndLimbOn       = False
  res@cnConstFLabelFontHeightF = 0.0 ; hide costant value

  res@mpDataBaseVersion     = "MediumRes"
  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"   ; "AllBoundaries"
 
  res@cnLevelSpacingF       = 5
  res@lbOrientation         = "Vertical"
 
;---Zoom
  minlat  =  min(lat2d)                                 ;-- retrieve minimum latitude value
  minlon  =  min(lon2d)                                 ;-- retrieve maximum latitude value
  maxlat  =  max(lat2d)                                 ;-- retrieve minimum longitude value
  maxlon  =  max(lon2d)                                 ;-- retrieve maximum longitude value
  ; --------------------------------------------------------------------------
  ; --- mpProjection defines the projection used for the map transformation
  ; --------------------------------------------------------------------------
  ; res@mpProjection          = "Orthographic"           ;-- change projection
  ; res@mpProjection          = "Stereographic"
  ; res@mpProjection            =  "Gnomonic"
  ; res@mpProjection            =  "LambertEqualArea"
  ; res@mpProjection            =  "AzimuthalEquidistant"
;   res@mpProjection            =  "Satellite"
;   res@mpProjection            =  "PseudoMollweide"
  ; res@mpProjection            =  "Mercator"
  ; res@mpProjection            =  "CylindricalEquidistant"
;   res@mpProjection            =  "LambertConformal"
;   res@mpProjection            =  "Robinson"
  ; res@mpProjection            =  "CylindricalEqualArea"
  ; res@mpProjection            =  "RotatedMercator"
  
  ; --------------------------------------------------------------------------

  res@mpGridAndLimbOn       =  True                    ;-- turn on grid lines
  res@mpCenterLatF          =  minlat + (maxlat -minlat)/2 ;-- center point of view latitude
  res@mpCenterLonF          =  minlon + (maxlon -minlon)/2 ;-- center point of view longitude
  res@mpLimitMode           = "LatLon"                 ;-- map limits mode
  res@mpMinLatF             =  minlat - 0.5            ;-- set min lat
  res@mpMaxLatF             =  maxlat + 0.5            ;-- set max lat
  res@mpMinLonF             =  minlon - 1.             ;-- set min lon
  res@mpMaxLonF             =  maxlon + 1.             ;-- set max lon
;   res@mpPerimOn             =  False                   ;-- don't draw the box around the plot

  res@mpGridAndLimbDrawOrder = "Predraw"
  res@tiMainString           = "Lat/lon grid"

;---Plot will just be created, and not drawn yet.
  plot = gsn_csm_contour_map(wks,domains(:,:),res)

;----------------------------------------------------------------------
; Draw the lat/lon grid with markers, using black for grid locations
; where the data is not missing, and yellow for grid locations
; where the data is missing.
;---------------------------------------------------------------------
  pres                          = True
  pres@gsnCoordsNonMissingColor = "yellow"
  pres@gsnCoordsMissingColor    = "black"
  pres@gsMarkerSizeF            = 5.0
  gsn_coordinates(wks,plot,domains(:,:),pres)

;----------------------------------------------------------------------
; Draw lines at the lon/lon coordinate array values.
; Marker resources set above will be ignored.
;----------------------------------------------------------------------
  pres@gsnCoordsAsLines  = True
  pres@gsLineThicknessF  = 2
  gsn_coordinates(wks,plot,domains(:,:),pres)

end
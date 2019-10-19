;标识，多边形，任意折线和文本
;注意多个res的合并是如何完成的
begin
  ;南京经纬度
  lat_nj = 32.03  
  lon_nj = 118.46              

  ;假定一低压系统中心在某5天中的经纬度位置 
  lat_line = (/20,21,22,24,27,29/)
  lon_line = (/124,122.5,120,119,120,121/)
    
  ;假定该低压系统在后4天中的影响范围如下
  center_lat = 25     
  center_lon = 120   
  maxlat_region = center_lat+5
  minlat_region = center_lat-5
  maxlon_region = center_lon+3  
  minlon_region = center_lon-3 
  
  wks = gsn_open_wks("x11","poly_ex")

  res           = True                        ; plot mods desired
  res@gsnFrame    = False
  res@gsnDraw     = False                     ; don't draw plot yet

  res@mpMinLatF   = 15                      ; zoom in on a subregion
  res@mpMaxLatF   = 40
  res@mpMinLonF   = 110
  res@mpMaxLonF   = 130
  
  res@pmTickMarkDisplayMode = "Always" ;坐标标签上添加度符号
  
  map = gsn_csm_map(wks,res)    

;;添加多边形的序列。注意，要使图形闭合，需最后一个点的位置需与第一个点重合
  boxlat = (/ maxlat_region,  maxlat_region, minlat_region,  minlat_region, maxlat_region/)
  boxlon = (/minlon_region, maxlon_region,maxlon_region, minlon_region,minlon_region/)   

  gonres                  = True             
  gonres@gsFillColor      = "black"
  gonres@gsFillOpacityF   = 0.5 ; 50%透明
  dum = gsn_add_polygon(wks, map, boxlon, boxlat, gonres)

;;添加任意折线(即低压中心的移动路径) 
  lnres                   = True                      
  gonres@gsfillcolor      = "black"
  lnres@gsLineThicknessF  = 3.0
  lnres@gslinedashpattern = 16 ;gslinedash线型，去查手册
  dum2 = gsn_add_polyline(wks, map, lon_line, lat_line, lnres)

;;添加marker（即低压中心位置）
  mkres                  = True       
  mkres@gsmarkercolor    = "black"
  mkres@gsMarkerSizeF    = 0.01 ; 标识点的大小，在0-1的范围之内设置
  mkres@gsMarkerIndex    = 14 ;
  dum22 = gsn_add_polymarker(wks, map, lon_line, lat_line, mkres)   

;;添加marker(南京位置) 
  mkres@gsMarkerColor    = "black"
  mkres@gsMarkerSizeF    = 0.02
  mkres@gsMarkerIndex    = 3
  dum3 = gsn_add_polymarker(wks, map, lon_nj, lat_nj, mkres)         


  ;;添加文字
  txres                  = True
  txres@txFontHeightF    = 0.015
  txres@txFontColor      = "black"
  dum4 =gsn_add_text(wks, map, "NanJing", lon_nj, lat_nj+2, txres)

  
  draw(map)
  frame(wks)
    
end
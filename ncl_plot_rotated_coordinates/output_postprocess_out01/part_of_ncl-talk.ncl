 ;  先进行设置：
 res@tfDoNDCOverlay        = True

 lat = ... ; 2d-array of geographical latitudes
 lon = ... ; 2d-array of geographical longitudes
 pollat = 43.0 ; latitude of rotated pole
 pollon = -170.0 ; longitude of rotated pole
 r = True
 r_at_cnFillOn = True
 r_at_cnLinesOn = False
 r_at_gsnSpreadColors = True
 r_at_mpDataBaseVersion = "MediumRes"
 r_at_mpProjection = "CylindricalEquidistant"
 r_at_mpProjection = "CylindricalEquidistant"
 r_at_mpCenterLonF = 180.0+pollon
 r_at_mpCenterLatF = 90.0-pollat
 r_at_mpLimitMode = "Corners"
 r_at_mpLeftCornerLatF = lat(0,0)
 r_at_mpLeftCornerLonF = lon(0,0)
 r_at_mpRightCornerLatF = lat(s(0)-1,s(1)-1)
 r_at_mpRightCornerLonF = lon(s(0)-1,s(1)-1)
 plt = gsn_csm_contour_map(wks,f,r)
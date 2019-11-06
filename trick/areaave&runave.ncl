; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin
  f_v = addfile("./practice/lx_ex_data/vwnd.mon.mean.nc", "r")
  f_u = addfile("./practice/lx_ex_data/uwnd.mon.mean.nc", "r")
  ; list_filevars(f_v)
  v_slect = f_v->vwnd(:, {850}, {20:40}, {110:145}) ; 元数据无法使用 坐标变量名 + 范围 的方式检索
  u_slect = f_u->uwnd(:, {850}, {20:40}, {110:145}) ; time x level x lat x lon
  v_areamean = wgt_areaave_Wrap(v_slect, 1., 1., 0) ; 将经纬度放在最右侧的区域平均
  u_areamean = wgt_areaave_Wrap(u_slect, 1., 1., 0)
  v_areamean&time = cd_calendar(v_areamean&time, 1) ; 改变时间坐标属性
  u_areamean&time = cd_calendar(u_areamean&time, 1)


  v_time_mo_to_year = month_to_annual(v_areamean({time|194801:201712}), 0)
  u_time_mo_to_year = month_to_annual(u_areamean({time|194801:201712}), 0)
  ; printVarSummary(v_time_mty)
  v_runave = runave_Wrap(v_time_mo_to_year, 5, 0) ; v五年滑动平均
  u_runave = runave_Wrap(u_time_mo_to_year, 5, 0) ; 

  year = ispan(1948,2017,1)
;; (5) plot
  plot = new(2,graphic)  
  wks = gsn_open_wks("png","plot-vu")
  gsn_define_colormap(wks,"rainbow")  
         
  res           = True              
  res@gsnDraw   = False ; 暂不画
  res@gsnFrame  = False ; 暂不翻页
  
  res2 = res
;;res setting
  res@vpHeightF = 0.35  ; 改变viewport的大小
  res@vpWidthF  = 0.6   ; 

  res@trXMinF   = 1948  ; 设定X轴坐标范围
  res@trXMaxF   = 2017
  res@trYMaxF   = 30  ; 设定Y轴坐标范围
  res@trYMinF   = 0 

  ;设定大于与小于0时的填色
  res@gsnYRefLine = 0.                              ; 设定参考值。
  res@gsnAboveYRefLineColor = "light gray"          ; 大于该参考值所用的颜色
  res@gsnBelowYRefLineColor = "white"               ; 小于该参考值所用的颜色

  res@tiXAxisString = "year"   ; 添加X轴名称   
  res@tiYAxisString = "v-areaave"    ; 添加Y轴名称 
;;res2 setting
  res2@xyLineColor = "black"
  res2@xyLineThicknessF = 4. 


  plot(0) = gsn_csm_xy(wks, year, v_time_mo_to_year, res)       
  plotv_mean = gsn_csm_xy(wks, year, v_runave, res2)
  res@trYMaxF = 40
  res@trYMinF = 10
  plot(1) = gsn_csm_xy(wks, year, u_time_mo_to_year, res)
  plotu_mean = gsn_csm_xy(wks, year, u_runave, res2)
  overlay(plot(0),plotv_mean)
  overlay(plot(1),plotu_mean)  
;叠加两张图
  ; pres = True
  ; pres@txString              = "Paneling"
  ; pres@gsnPanelLabelBar      = True ; 公用一个色标
  ; pres@gsnPanelFigureStrings = (/"A","B"/)
  ; pres@amJust                = "TopLeft" ;调整标签顺序

  gsn_panel(wks,plot,(/2,1/),False)
  ; draw(plot) 
  ; frame(wks)  
end

;  annual taylor diagram绘制
;    前处理的计算过程中 使用taylor_stats函数，OBS和MOD错位，计算结果错误；已弃用   
;**********************************
load "./taylor_diagram.ncl"
load "./taylor_stats.ncl"
load "./taylor_metrics_table.ncl"
;**********************************
begin

;>>>---------------------------------------------------整理tylor绘图数据
; 注意名称的对应
file_num = 3
f_tm_mod1_cat = addfile("./practice/bc_data/temporary_data/bc_tm/taylor/taylor_wrf"+".nc", "r")
f_tm_mod2_cat = addfile("./practice/bc_data/temporary_data/bc_tm/taylor/taylor_cclm"+".nc", "r")
f_tm_mod3_cat = addfile("./practice/bc_data/temporary_data/bc_tm/taylor/taylor_regcm"+".nc", "r")
;统计结果保存,数组序号作为第几个模型
bc_o = new((/file_num,8/),"float")
mod_o = new((/file_num,8/),"float")

bc_o(0,:) = f_tm_mod1_cat->$"stats_bc"$
mod_o(0,:)    = f_tm_mod1_cat->$"stats_mod"$

bc_o(1,:) = f_tm_mod2_cat->$"stats_bc"$
mod_o(1,:)    = f_tm_mod2_cat->$"stats_mod"$

bc_o(2,:) = f_tm_mod3_cat->$"stats_bc"$
mod_o(2,:)    = f_tm_mod3_cat->$"stats_mod"$   

;整合到ratio和cc两个数组 CASE A作为OBS-MOD ;CASE B作为OBS-BC
ratio_bc_o  = bc_o(:,1)
ratio_mod_o = mod_o(:,1)
cc_bc_o     = bc_o(:,0)
cc_mod_o    = mod_o(:,0)
;**********************************
; Assume the following have already been computed:
;   _ratio are the ratio:  Case_Variance/Reference_Variance
;   _cc    are the cross correlation coef of Case to Reference
;**********************************
;A:mod_o B:bc_o
; Cases [Model]
  case      = (/"MOD-OBS", "BC-OBS"/) 
  nCase     = dimsizes(case)                 ; # of Cases [Cases]

; variables compared
  var       = (/ "WRF","CCLM","RegCM"/) 
  nVar      = dimsizes(var)                   ; # of Variables

; "Case A"                        
  CA_ratio   = (ratio_mod_o)
  CA_cc      = (cc_mod_o)

; "Case B" 
  CB_ratio   = (ratio_bc_o)
  CB_cc      = (cc_bc_o)

; arrays to be passed to taylor plot 
  ratio      = new ((/nCase, nVar/),typeof(CA_cc) )  
  cc         = new ((/nCase, nVar/),typeof(CA_cc) ) 

  ratio(0,:) = CA_ratio 
  ratio(1,:) = CB_ratio

  cc(0,:)    = CA_cc 
  cc(1,:)    = CB_cc

;>>>---------------------------------------------------作图

  ; varSource = var +"_"+ source              ; add extra info [*not* required]

  ty_opt   = True                           ; taylor diagram with options
        
  ty_opt@Markers       = (/16, 16/)         ; make all solid fill
  ty_opt@Colors        = (/"red", "blue" /)          
  ty_opt@varLabels     = var
  ty_opt@caseLabels    = case

  ty_opt@varLabelsYloc = 1.5                ; Move location of variable labels [default 0.45]
  ty_opt@caseLabelsFontHeightF = 0.14       ; make slight larger   [default=0.12 ]
  ty_opt@varLabelsFontHeightF  = 0.010      ; make slight smaller  [default=0.013]
 
  ty_opt@tiMainString  = "20000101-20011231"           ; title
  ty_opt@stnRad        = (/ 0.5, 1.5 /)     ; additional standard radii
  ty_opt@ccRays        = (/ 0.6, 0.9, 0.99/)     ; correllation rays
  ty_opt@centerDiffRMS = True               ; RMS 'circles'

  wks   = gsn_open_wks("x11","./practice/bc_data/temporary_data/taylor_01")      ; send graphics to PNG file
  plot  = taylor_diagram(wks,ratio,cc,ty_opt)

; ;**************************************************
; ; fill an array for a "taylor metrics table"
; ;**************************************************

;   ; season    = (/ "ANN" /)
;   ; nSeason   = dimsizes(season)

;   ; table     = new ( (/nCase,nSeason,nVar/), typeof(ratio) )
;   ; table(0,0,:) = CA_ratio
;   ; table(1,0,:) = CB_ratio

;   ; tt_opt        = True
;   ; tt_opt@pltType= "x11"                  ; "eps" [default], "pdf", "ps"
;   ;                                        ; "png", "gif" [if you have ImageMajik 'convert']
;   ; tt_opt@color0 = "palegreen2"
;   ; tt_opt@color1 = "tomato2"


;   ; taylor_metrics_table("taylor.000002", varSource, case ,season, table, tt_opt)
end
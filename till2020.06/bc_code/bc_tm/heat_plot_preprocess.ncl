;  3.31 ��R����ͼ RMSE ��Ԥ����
;    Ŀ�� �� �������µ�ƽ��ͼRMSE���
;  4.1 ����mask�ļ����ɴ��н�ȡע���е�����
;    ǰ��������: tm_ordata_part.ncl
;  load "./pvs.ncl"
 ; load "./box_percentile_plot.ncl"
 ;************************************************
 begin ; program
 ;>>>-------------------�������ݣ�MOD1-3 WRF CCLM REGCM
type = "pre"
    f_cat_1 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_WRF_step2.nc","r")
  ; ;>>>>05.1�۲����ݼ�,ƽ������
    obs_or = f_cat_1->$"tm_cn051_step2"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    mod1_or = f_cat_1->$"tm_wrf_step2"$
  f_cat_2 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_CCLM_step2.nc","r")
    mod2_or = f_cat_2->$"tm_wrf_step2"$
  f_cat_3 = addfile("./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/tm_cat_CN051_RegCM_step2.nc","r")
    mod3_or = f_cat_3->$"tm_wrf_step2"$
;>>>read data from BC result
  bcname = (/"wrf","cclm","regcm"/)
  path_bc = "./practice/bc_data/temporary_data/bc_"+type+"/r_to_ncl/bc_"+type+"_"+bcname+".nc"
  f_bc_1 = addfile(path_bc(0), "r")
    mod1_bc = f_bc_1->$"bc_tm"$
  f_cat_2 = addfile(path_bc(1),"r")
    mod2_bc = f_cat_2->$"bc_tm"$
  f_cat_3 = addfile(path_bc(2),"r")
    mod3_bc = f_cat_3->$"bc_tm"$
;>>>-------------------------------------------------������
  time_or = cd_calendar(obs_or&time, 0) ; time_orΪ730 x 6 6��ʱ��ֱ���yy mm dd hh mm ss
  ; ������ȡ�����
  ind_list = NewList("fifo")
  ; ind_month = ind(time_or(:,1).eq.1)
  do i = 1, 12
    ListAppend(ind_list, ind(time_or(:,1).eq.i)) ; list 0 - 11 ��������time�� IND���
  end do
  ; pvs(ind_list)
;>>>------������� �账������ mod[]_or mod[]_bc obs_or
  f_mask = addfile("./practice/bc_data/temporary_data/bc_tm/parts/mask"+".nc", "r")
  mask_check = f_mask->$"mask_check"$
  mod_rmse = new((/10,3,12/), float) ; [����]x[ģʽ��]x[month]
  bc_rmse  = new((/10,3,12/), float)
do iii = 0, 10 - 1
  check_num = iii + 1
; (0)    [ע���ǿգ�����û�У�]
; (1)     H ��ԭ������
; (2)     I ���´�
; (3)     II ���´�
; (4)     III ���´�
; (5)     IV �����ȴ�
; (6)     IX ���ȴ�
; (7)     V �����ȴ�
; (8)     VI �����ȴ�
; (9)     VII �����ȴ�
; (10)    VIII ���ȴ�
  ; printVarSummary(mask_check)
  ; printVarSummary(obs_or)
  ; dim_obs_or = dimsizes(obs_or)
  mask_check_conform = conform(obs_or, mask_check, (/1,2/))
  ; print(ind(ndtooned(mask_check).eq.check_num))
  ; printVarSummary(mask_check_conform)
  ; print(sum(mask_check_conform(0,:,:)-mask_check))
  obs_or_count = where(mask_check_conform.eq.check_num, obs_or, obs_or@_FillValue) ; ������obs_or�ıȽ����Ǻܷ�����
  ; print(sum(obs_or_nchange))
;>>>--------------------------------------------------��������RMSE

  do i = 0, 11

    ; 0[WRF],i[month]
    mod_rmse(iii,0,i) = dim_rmsd_n(mod1_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 1[CCLM],i[month]
    mod_rmse(iii,1,i) = dim_rmsd_n(mod2_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 2[REGCM],i[month]
    mod_rmse(iii,2,i) = dim_rmsd_n(mod3_or(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 0[WRF],i[month]
    bc_rmse(iii,0,i)  = dim_rmsd_n(mod1_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 1[CCLM],i[month]
    bc_rmse(iii,1,i)  = dim_rmsd_n(mod2_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
    ; 2[REGCM],i[month]
    bc_rmse(iii,2,i)  = dim_rmsd_n(mod3_bc(ind_list[i],:,:), obs_or_count(ind_list[i],:,:), (/0,1,2/))
  end do
  print("----------------------------s-------------------------------")
  print(iii)
  ; printVarSummary(mod_rmse)
  print(mod_rmse(iii,:,:))
  print(bc_rmse(iii,:,:))
  delete(mask_check_conform)
end do
; ;>>>----------------------------------------------- �ݴ���
;>>>Ԥ����ͼ���� ��ͼ���� mod_rmse bc_rmse
  path_out_step1 = "./practice/bc_data/temporary_data/bc_"+type+"/ncl_to_r/"+type+"_rmse_bind2_"+check_num+".nc"
  system("rm -f "+path_out_step1) ;ɾ��Ŀ¼�µ�ͬ���ļ�
  ncdf_step1 = addfile(path_out_step1, "c") ; c��ʾ����netcdf�ļ�
  ncdf_step1->mod_rmse  = mod_rmse ;д�������ֵ
  ncdf_step1->bc_rmse   = bc_rmse
  delete(ncdf_step1)


end
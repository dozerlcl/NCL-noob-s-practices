;CN0.1_Tm_198901_200912_daily_025x025 �� WRF_TMEAN_daily_025x025 �����ļ��Ķ�ȡ�����ű�
;���ռ�ϵ��cor����������prob��ƽ�����minus_ave ���浽 tm_or_CN051_WRF �ļ���
;3.13 ��mod�ļ���wrf��Ϊcclm
;ע�������wrfָģʽ��CN051ָ�۲�
;3.16 ���Ӵ��� RegCM_TMEAN_daily_025x025
;3.31 �޸�Ϊ����RMSE�Ĳ���
begin
;>>>read CN05.1 data
modname = "WRF"   
  f_CN051_TM = addfile("./practice/bc_data/CN05.1_Tm_198901_200912_daily_025x025.nc", "r")
  f_WRF_TM   = addfile("./practice/bc_data/"+modname+"_TMEAN_daily_025x025.nc","r")
  ; f_WRF_TM  = addfile("./practice/bc_data/CCLM_TMEAN_daily_025x025.nc","r")
  ;;;;;���Ƕ�ȡ����ģ�20000101-20011231����¼��Ϊ��4017-4747��   ���ݹ�����һ���Զ��������
  ;>>>>05.1�۲����ݼ�,ƽ������
    ; list_filevars(f_CCLM_TM) 
    tm_CN051_or = f_CN051_TM->$"tm"$;CN05.1 tm [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    ; printVarSummary(tm_CN051&time) ; ���ñ�����time���� 19890101-20091231 ��������
    ; tm_CN051_time = cd_calendar(tm_CN051&time, 2)
    ; it_s=20000101  ;��ʼ����
    ; it_e=20011231  ;��������
    ; rec_s = ind(it_s .eq. tm_CN051_time)      ;��ȡ��ʼʱ��ļ�¼�� 4017
    ; rec_e = ind(it_e .eq. tm_CN051_time)      ;��ȡ����ʱ��ļ�¼�� 4747
    ; print(rec_s)
    ; print(rec_e)
    tm_CN051_cat = tm_CN051_or(time|4017:4747,lat|:,lon|:) ;�ü�¼�Ž�ȡ
    ; tm_CN051_cat = tm_CN051_or({time|341856:359376},lat|:,lon|:) ;�þ������ݷ�Χ��ȡ
    delete(tm_CN051_or)
  ;>>>>WRFģʽ��ƽ������
    ; list_filevars(f_WRF_TM) 
    tm_wrf_or = f_WRF_TM->$"TMEAN"$;TMEAN [ time | 7670 ] x [ lat | 163 ] x [ lon | 283 ]
    tm_wrf_cat = tm_wrf_or(time|4017:4747,lat|:,lon|:) 
    delete(tm_wrf_or)
  ;>>>������� CN051 unit: C wrf_cat unit K
  ;#################################################################################
  if(modname.eq."WRF")
    tm_wrf_cat = tm_wrf_cat -273.15
  end if
  ;#################################################################################
;>>>����ռ����ϵ��

  cor_tm = escorc_n(tm_wrf_cat, tm_CN051_cat, 0, 0)
  prob_tm = rtest(cor_tm, 731, 0)
  copy_VarMeta(tm_wrf_cat(0,:,:),cor_tm)
  copy_VarMeta(tm_wrf_cat(0,:,:),prob_tm)
  ; write_matrix(prob_tm, "15F10.6", False)
  ;---------------------------------------------------------ȱʧֵ���(��where���м��)
  ; obs_tm_good = where(.not.ismissing(tm_CN051_cat), 1, 0)
  ; obs_tm_good_sum = dim_sum_n(obs_tm_good, 0)
  ; printVarSummary(obs_tm_good_sum)
  ; write_matrix(obs_tm_good_sum, "15I7", False)
  ;-------------------------------------------------OBS�е�ȱʧֵ���� ��ȫȱʧ��ʱ�����в�ȱʧ���������
;>>>�������
  minus = tm_wrf_cat - tm_CN051_cat
  ; printVarSummary(minus)
  minus = abs(minus)
    ; printMinMax(minus,1)
  minus_ave = dim_avg_n(minus, 0)
  copy_VarMeta(tm_wrf_cat(0,:,:),minus_ave)
  rmse = dim_rmsd_n(tm_wrf_cat, tm_CN051_cat, 0) ; ʱ������rmse���ÿռ�ͼ  
  copy_VarMeta(tm_wrf_cat(0,:,:),minus_ave)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),cor_tm_bc)
  ; copy_VarMeta(tm_cn051_needed(0,:,:),prob_tm_bc)
  copy_VarMeta(tm_wrf_cat(0,:,:),rmse)
  printVarSummary(rmse)
  printMinMax(rmse, 1)
  ; printVarSummary(minus_ave)
;>>>Ԥ����ͼ���� ��ͼ���� cor_tm(WRF&cn05.1)
  path_out = "./practice/bc_data/temporary_data/bc_tm/tm_or_CN051_"+modname+"_02"+".nc"
  system("rm -f "+path_out) ;ɾ��Ŀ¼�µ�ͬ���ļ�
  ncdf = addfile(path_out, "c") ; c��ʾ����netcdf�ļ�
  ; ncdf->cor_tm_WRF_CN051 = cor_tm ;д�������ֵ
  ; ncdf->prob = prob_tm
  ncdf->minus_ave_tm_WRF_CN051 = minus_ave
  ncdf->rmse = rmse
  delete(ncdf)
;>>>��ͼ�����ռ����ϵ��

end
              
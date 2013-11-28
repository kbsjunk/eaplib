--
-- Database: `appreq`
--
CREATE DATABASE IF NOT EXISTS `eaplib` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `eaplib`;

-- --------------------------------------------------------

--
-- Table structure for table `options`
--

CREATE TABLE IF NOT EXISTS `options` (
  `option_name` varchar(255) NOT NULL,
  `option_value` varchar(255) DEFAULT NULL,
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`option_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `options`
--

INSERT INTO `options` (`option_name` ) VALUES
('current_environment'),
('last_import');

-- --------------------------------------------------------

--
-- Table structure for table `uom_sql_queries`
--

CREATE TABLE IF NOT EXISTS `uom_sql_queries` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `descr` varchar(80) DEFAULT NULL,
  `query` text,
  `output_file` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=21 ;

--
-- Dumping data for table `uom_sql_queries`
--

INSERT INTO `uom_sql_queries` (`id`, `descr`, `query`, `output_file`) VALUES
(1, 'Application Requirements', '  SELECT \n  app_rqmnt_cd,\n  app_rqmnt_descr,\n  app_rqmnt_full_descr,\n  active_fg,\n  doc_rqmnt_comp_fg,\n  resp_prompt_fg,\n  max_number_responses,\n  default_number_responses,\n  required_number_responses,\n  parent_app_rqmnt_cd,\n  app_subreq_crit_grp_id AS sub_req_crt_grp\n  FROM \n  [ENV]s1eap_app_rqmnt_det', 'app_req'),
(2, 'Document Requirements', 'SELECT\n  doc_rqmnt_cd,\n  doc_rqmnt_descr,\n  doc_rqmnt_full_descr,\n  stu_doc_type_cd,\n  doc_no_prompt_fg,\n  doc_no_prompt_descr,\n  issue_dt_prompt_fg,\n  issue_dt_prompt_descr,\n  expy_dt_prompt_fg,\n  expy_dt_prompt_descr,\n  active_fg,\n  add_info_link_src_cd,\n  add_info_link_name,\n  add_info_url_txt,\n  add_info_dir_code_type,\n  add_info_dir_code,\n  add_info_file_name,\n  add_info_link_lbl_disp_fg,\n  add_info_link_lbl_txt\n  FROM \n  [ENV]s1eap_doc_rqmnt_det', 'doc_req'),
(3, 'Application Requirement Document Requirements', 'SELECT \n  app_rqmnt_cd,\n  doc_rqmnt_cd,\n  online_submit_fg,\n  physical_submit_fg\n  FROM \n  [ENV]s1eap_app_rqmnt_doc_rqmnts', 'app_doc_req'),
(4, 'Standard Codes', 'SELECT \n  code_type,\n  code_type_descr,\n  maint_by_code\n  FROM \n  [ENV]s1stc_code_type\n  WHERE\n  code_type IN \n  (SELECT distinct \n  CODE_TYPE\n  FROM \n  [ENV]s1usr_response_field\n  WHERE\n  response_field_entity_type = ''APP_REQ'')', 'std_cd'),
(5, 'Standard Code Values', 'SELECT \n  code_type,\n  code_id,\n  code_descr,\n  active_flag as active_fg,\n  seq_no,\n  maint_by_code\n  FROM \n  [ENV]s1stc_code\n  WHERE\n  code_type IN \n  (SELECT distinct \n  CODE_TYPE\n  FROM \n  [ENV]s1usr_response_field\n  WHERE\n  response_field_entity_type = ''APP_REQ'')', 'std_cd_val'),
(6, 'Application Requirement Response Fields', 'SELECT \n  key1 AS app_rqmnt_cd,\n  label,\n  data_type,\n  watermark,\n  hint_text,\n  skin_id,\n  code_type,\n  maximum_length,\n  mandatory_fg,\n  seq_no,\n  response_field_id\n  FROM \n  [ENV]s1usr_response_field\n  WHERE\n  response_field_entity_type = ''APP_REQ'' AND\n  deleted_fg = ''N''', 'usr_fld'),
(7, 'Application Requirement Standard Codes', 'SELECT DISTINCT \n  key1 AS app_rqmnt_cd,\n  code_type \n  FROM \n  [ENV]s1usr_response_field\n  WHERE\n  response_field_entity_type = ''APP_REQ'' AND\n  code_type <> '' ''', 'app_req_std_cd'),
(8, 'Study Package Category Types', 'SELECT \n  spk_cat_type_cd,\n  spk_cat_type_desc,\n  spk_cat_lvl_cd,\n  study_type_cd,\n  allow_online_app_fg AS self_apply_fg\n  FROM \n  [ENV]s1cat_type\n  WHERE\n  spk_cat_cd = ''CO''', 'spk_cat'),
(9, 'Study Package Category Type Application Requirements', ' SELECT \n  app_rqmnt_cd,\n  spk_cat_type_cd,\n  seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_spk_cat_type_app_rqmnts', 'spk_cat_app_req'),
(10, 'Study Package Application Requirements', 'SELECT \n  spk_cd,\n  spk_ver_no,\n  spk_cd||''/''||spk_ver_no AS spk_id,\n  app_rqmnt_cd,\n  seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_spk_app_rqmnts\n  INNER JOIN [ENV]s1spk_det USING (spk_no, spk_ver_no)', 'spk_app_req'),
(11, 'Study Packages', 'SELECT DISTINCT \n  spk.spk_no,\n  spk.spk_cd,\n  spk.spk_cat_type_cd,\n  spk.spk_full_title,\nCASE WHEN crsa.spk_no IS NULL THEN ''N'' ELSE ''Y'' END AS self_apply_fg\n  FROM \n  [ENV]s1spk_det spk\n  LEFT JOIN [ENV]s1spk_crse_availabilities crsa ON\n  (spk.spk_no = crsa.spk_no AND spk.spk_ver_no = crsa.spk_ver_no) \n  WHERE\n  spk.spk_cat_cd = ''CO'' AND\n  (spk.spk_no IN \n  (SELECT \n  spk_no\n  FROM \n  [ENV]s1eap_spk_app_rqmnts) OR spk.spk_cat_cd IN \n  (SELECT \n  spk.spk_cat_cd\n  FROM \n  [ENV]s1eap_spk_cat_type_app_rqmnts))', 'spk_cd'),
(12, 'Study Package Versions', 'SELECT DISTINCT \n  spk.spk_no,\n  spk.spk_cd,\n  spk.spk_ver_no,\n  spk.spk_cd||''/''||spk.spk_ver_no AS spk_id,\n  spk.spk_cat_type_cd,\n  spk.spk_stage_cd,\n  spk.spk_full_title,\nCASE WHEN crsa.spk_no IS NULL THEN ''N'' ELSE ''Y'' END AS self_apply_fg\n  FROM \n  [ENV]s1spk_det spk\n  LEFT JOIN [ENV]s1spk_crse_availabilities crsa ON\n  (spk.spk_no = crsa.spk_no AND spk.spk_ver_no = crsa.spk_ver_no) \n  WHERE\n  spk.spk_cat_cd = ''CO'' AND\n  (spk.spk_no IN \n  (SELECT \n  spk_no\n  FROM \n  [ENV]s1eap_spk_app_rqmnts) OR spk.spk_cat_cd IN \n  (SELECT \n  spk.spk_cat_cd\n  FROM \n  [ENV]s1eap_spk_cat_type_app_rqmnts))', 'spk_ver'),
(13, 'eApplication Submission Texts', 'SELECT \n  eap_rspns_cd,\n  eap_rspns_descr,\n  eap_rspns_text\n  FROM \n  [ENV]s1eap_rspns_det', 'cnf_em'),
(14, 'Application Requirement Display Criteria', 'SELECT \n  crt.app_rqmnt_cd,\n  crt.crit_type,\n  stct.code_descr AS crit_name,\n  crt.crit_op,\n  crto.code_descr AS crit_descr,\n  itm.crit_value_alpha AS crit_code,\n  stc.code_descr AS crit_value\n  FROM \n  [ENV]s1eap_app_rqmnt_crit_det crt\n  INNER JOIN [ENV]s1eap_crit_items itm ON\n  ( crt.app_rqmnt_cd = itm.entity_id AND crt.crit_type = itm.crit_type AND itm.entity_type = ''APPREQ'' ) \n  LEFT JOIN [ENV]s1stc_code stc ON\n  ( itm.crit_type = stc.code_type AND itm.crit_value_alpha = stc.code_id ) \n  LEFT JOIN [ENV]s1stc_code stct ON\n  ( itm.crit_type = stct.code_id AND stct.code_type = ''S1_EAP_CRIT_TYPE'' ) \n  LEFT JOIN [ENV]s1stc_code crto ON\n  ( crt.crit_op = crto.code_id AND crto.code_type = ''S1_EAP_CRIT_OP'' ) \n  WHERE\n  crt.crit_type <> ''CITIZENSHIP'' \n  UNION \n  SELECT DISTINCT \n  crt.app_rqmnt_cd,\n  crt.crit_type,\n''Student''''s Citizenship'',\n''INCL'' AS crit_op,\n''One Of'' AS crit_descr,\nCASE WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''N'') ) THEN ''INT'' WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''N'') ) THEN ''DOM'' ELSE NULL END AS crit_code,\nCASE WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''N'') ) THEN ''International'' WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''N'') ) THEN ''Domestic'' ELSE NULL END AS crit_value\n  FROM \n  [ENV]s1eap_app_rqmnt_crit_det crt\n  INNER JOIN [ENV]s1eap_crit_items itm ON\n  ( crt.app_rqmnt_cd = itm.entity_id AND crt.crit_type = itm.crit_type AND itm.entity_type = ''APPREQ'' ) \n  LEFT JOIN [ENV]s1stc_code stc ON\n  ( itm.crit_type = stc.code_type AND itm.crit_value_alpha = stc.code_id ) \n  WHERE\n  crt.crit_type = ''CITIZENSHIP''', 'app_req_crt'),
(15, 'Institution Application Requirements', 'SELECT \n  app_rqmnt_cd,\n  seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_inst_app_rqmnts', 'inst_app_req'),
(16, 'Institution eApplication Submission Texts', 'SELECT \n  eap_rspns_cd,\n  eap_rspns_cd AS seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_inst_rspns', 'inst_cnf_em'),
(17, 'Application Subrequirement Criteria', ' SELECT \n  app_subreq_crit_id,\n  app_rqmnt_cd,\n  app_subreq_crit_grp_id AS sub_req_crt_grp,\n  response_field_id,\n  crit_op,\n  crit_value\n  FROM \n  [ENV]s1eap_app_subreq_crit', 'sub_req_crt'),
(18, 'eApplication Submission Text Criteria', 'SELECT \n  crt.eap_rspns_cd,\n  crt.crit_type,\n  stct.code_descr AS crit_name,\n  crt.crit_op,\n  crto.code_descr AS crit_descr,\n  itm.crit_value_alpha AS crit_code,\n  stc.code_descr AS crit_value\n  FROM \n  [ENV]s1eap_rspns_crit_det crt\n  INNER JOIN [ENV]s1eap_crit_items itm ON\n  ( crt.eap_rspns_cd = itm.entity_id AND crt.crit_type = itm.crit_type AND itm.entity_type = ''EAPRSPNS'' ) \n  LEFT JOIN [ENV]s1stc_code stc ON\n  ( itm.crit_type = stc.code_type AND itm.crit_value_alpha = stc.code_id ) \n  LEFT JOIN [ENV]s1stc_code stct ON\n  ( itm.crit_type = stct.code_id AND stct.code_type = ''S1_EAP_CRIT_TYPE'' ) \n  LEFT JOIN [ENV]s1stc_code crto ON\n  ( crt.crit_op = crto.code_id AND crto.code_type = ''S1_EAP_CRIT_OP'' ) \n  WHERE\n  crt.crit_type <> ''CITIZENSHIP'' \n  UNION \n  SELECT DISTINCT \n  crt.eap_rspns_cd,\n  crt.crit_type,\n''Student''''s Citizenship'',\n''INCL'' AS crit_op,\n''One Of'' AS crit_descr,\nCASE WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''N'') ) THEN ''INT'' WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''N'') ) THEN ''DOM'' ELSE NULL END AS crit_code,\nCASE WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''N'') ) THEN ''International'' WHEN crt.crit_type = ''CITIZENSHIP'' AND ( (crt.crit_op = ''EXCL'' AND stc.trln_code_id = ''Y'') OR (crt.crit_op = ''INCL'' AND stc.trln_code_id = ''N'') ) THEN ''Domestic'' ELSE NULL END AS crit_value\n  FROM \n  [ENV]s1eap_rspns_crit_det crt\n  INNER JOIN [ENV]s1eap_crit_items itm ON\n  ( crt.eap_rspns_cd = itm.entity_id AND crt.crit_type = itm.crit_type AND itm.entity_type = ''EAPRSPNS'' ) \n  LEFT JOIN [ENV]s1stc_code stc ON\n  ( itm.crit_type = stc.code_type AND itm.crit_value_alpha = stc.code_id ) \n  WHERE\n  crt.crit_type = ''CITIZENSHIP''', 'cnf_em_crt'),
(19, 'Study Package eApplication Submission Texts', 'SELECT \n  spk_cd,\n  spk_ver_no,\n  spk_cd||''/''||spk_ver_no AS spk_id,\n  eap_rspns_cd,\n  eap_rspns_cd AS seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_spk_rspns\n  INNER JOIN [ENV]s1spk_det USING (spk_no, spk_ver_no) \n  WHERE\n  eap_rspns_cd <> '' ''', 'spk_cnf_em'),
(20, 'Study Package Category Type eApplication Submission Texts', 'SELECT \n  eap_rspns_cd,\n  spk_cat_type_cd,\n  eap_rspns_cd AS seq_no,\n  active_fg\n  FROM \n  [ENV]s1eap_spkcattype_rspns\n  WHERE\n  eap_rspns_cd <> '' ''', 'spk_cat_cnf_em');

-- --------------------------------------------------------

--
-- Table structure for table `uom_tags`
--

CREATE TABLE IF NOT EXISTS `uom_tags` (
  `rec_type` varchar(10) DEFAULT NULL,
  `rec_cd` varchar(20) DEFAULT NULL,
  `tag` varchar(40) DEFAULT NULL,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rec_type` (`rec_type`,`rec_cd`,`tag`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=407 ;

--
-- Dumping data for table `uom_tags`
--

INSERT INTO `uom_tags` (`rec_type`, `rec_cd`, `tag`, `id`) VALUES
('app_req', 'INFO_DVM_ANIMAL_TEAC', 'Acceptance', 1),
('app_req', 'INFO_DVM_ANIM_HAND', 'Acceptance', 2),
('app_req', 'INFO_DVM_Q_FEVER', 'Acceptance', 3),
('app_req', 'INFO_DVM_TETANUS', 'Acceptance', 4),
('app_req', 'IP_RIGHTS_OSP', 'Acceptance', 5),
('app_req', 'IP_RIGHTS_RG', 'Acceptance', 6),
('app_req', 'IP_RIGHTS_TC', 'Acceptance', 7),
('app_req', 'RSLT_DISCLSRE_UMEP', 'Acceptance', 8),
('app_req', 'SAEX_DEC_GOODSTAND', 'Acceptance', 9),
('app_req', 'SAEX_EX_INST_APP', 'Acceptance', 10),
('app_req', 'UMEP_PARENTCONSENT', 'Acceptance', 11),
('app_req', 'UMEP_TEACH_PRINCIPAL', 'Acceptance', 12),
('app_req', 'ADVST_INTENT', 'Advanced Standing', 13),
('app_req', 'ADVST_INTENT_INT', 'Advanced Standing', 14),
('app_req', 'ADVST_INTENT_MLM', 'Advanced Standing', 15),
('app_req', 'ADVST_MC-JURISD', 'Advanced Standing', 16),
('app_req', 'ADVST_MENV', 'Advanced Standing', 17),
('app_req', 'AGT', 'Agent', 18),
('app_req', 'SAEX_SA_INST_AG_REP', 'Agent', 19),
('app_req', 'CHECKLIST_LHM_GC-QA', 'Checklist', 20),
('app_req', 'CHECKLIST_LHM_MC-TEM', 'Checklist', 21),
('app_req', 'CHECKLIST_UMEP', 'Checklist', 22),
('app_req', 'CAP_EDUC_PG', 'Educational Background', 23),
('app_req', 'CAP_EDUC_UG', 'Educational Background', 24),
('app_req', 'INFO_BIOSTATS', 'Educational Background', 25),
('app_req', 'INFO_BIOSTATS', 'Required Qualification', 26),
('app_req', 'INFO_HS_NURS_HUMANAT', 'Educational Background', 27),
('app_req', 'INFO_HS_NURS_HUMANAT', 'Required Qualification', 28),
('app_req', 'PRIOR_ED', 'Educational Background', 29),
('app_req', 'PRIOR_ED_SAEX', 'Educational Background', 30),
('app_req', 'PUB_RES_RHD', 'Other', 31),
('app_req', 'REQ_CW_DENSUR', 'Educational Background', 32),
('app_req', 'REQ_CW_DENSUR', 'Required Qualification', 33),
('app_req', 'REQ_CW_MED', 'Educational Background', 34),
('app_req', 'REQ_CW_MED', 'Required Qualification', 35),
('app_req', 'REQ_CW_PHYSIO', 'Educational Background', 36),
('app_req', 'REQ_CW_PHYSIO', 'Required Qualification', 37),
('app_req', 'REQ_CW_VETMED', 'Educational Background', 38),
('app_req', 'REQ_CW_VETMED', 'Required Qualification', 39),
('app_req', 'SAEX_HOME_INST', 'Other', 40),
('app_req', 'TH_CURRENT_RHD', 'Other', 41),
('app_req', 'TH_CW', 'Educational Background', 42),
('app_req', 'TH_RESEARCH', 'Educational Background', 43),
('app_req', 'TH_RHD', 'Educational Background', 44),
('app_req', 'TSCR_Y12', 'Educational Background', 45),
('app_req', 'ELP_GD', 'English Language', 46),
('app_req', 'ELP_GD_LOCAL', 'English Language', 47),
('app_req', 'ELP_GD_SAEX', 'English Language', 48),
('app_req', 'ELP_UG', 'English Language', 49),
('app_req', 'ELP_UG_LOCAL', 'English Language', 50),
('app_req', 'ELP_UG_SAEX', 'English Language', 51),
('app_req', 'GAM', 'Graduate Access', 52),
('app_req', 'GAM_GSHSS', 'Graduate Access', 53),
('app_req', 'GAM_MC-JURISD', 'Graduate Access', 54),
('app_req', 'GRT_MC-JURISD_CSP', 'Guaranteed Entry', 55),
('app_req', 'GRT_MC-JURISD_FEE', 'Guaranteed Entry', 56),
('app_req', 'INFO_DVM_GUARENTRY', 'Guaranteed Entry', 57),
('app_req', 'SOURCE_INT', 'Marketing', 58),
('app_req', 'SOURCE_LOC', 'Marketing', 59),
('app_req', 'POLICE_CHECK', 'Official Check', 60),
('app_req', 'WORK_CHILD_CHECK', 'Official Check', 61),
('app_req', 'ANY_OTHER_INFO', 'Other', 62),
('app_req', 'APP_ASSIST', 'Other', 63),
('app_req', 'CAP_CURR_APPROVAL', 'Other', 64),
('app_req', 'CAP_PURPOSE', 'Other', 65),
('app_req', 'CHESSN', 'Other', 66),
('app_req', 'COM_DT', 'Other', 67),
('app_req', 'FEE_DISCOUNT', 'Other', 68),
('app_req', 'FOLIO_ABP', 'Other', 69),
('app_req', 'INFO_DVM_ACADIS_STMN', 'Other', 70),
('app_req', 'INFO_DVM_PREVAPPLN', 'Other', 71),
('app_req', 'INFO_MC-JURISD_COM', 'Other', 72),
('app_req', 'INFO_MLM_BUSADDRESS', 'Other', 73),
('app_req', 'INFO_SAEX_FAC', 'Other', 74),
('app_req', 'INTAKE_4TERM', 'Other', 75),
('app_req', 'MC-SCI_RTPS', 'Other', 76),
('app_req', 'PASSPORT', 'Other', 77),
('app_req', 'PHOTO_2', 'Other', 78),
('app_req', 'SAEX_DURATION', 'Other', 79),
('app_req', 'SAEX_PVD', 'Other', 80),
('app_req', 'UMEP_ADD_ASSIST', 'Other', 81),
('app_req', 'UMEP_SCHOOL_CENTRE', 'Other', 82),
('app_req', 'UMEP_VCAA_NUMBER', 'Other', 83),
('app_req', 'INFO_RHD', 'Personal Statement', 84),
('app_req', 'INFO_UG', 'Personal Statement', 85),
('app_req', 'STMENT_PERS_GEN_1000', 'Personal Statement', 86),
('app_req', 'STMENT_PERS_GEN_250', 'Personal Statement', 87),
('app_req', 'STMENT_PERS_GEN_500', 'Personal Statement', 88),
('app_req', 'STMENT_PERS_LMHM', 'Personal Statement', 89),
('app_req', 'STMNT_244CW', 'Personal Statement', 90),
('app_req', 'STMNT_INTENT_MC-EMA', 'Personal Statement', 91),
('app_req', 'STMNT_PERS_ABP_CW', 'Personal Statement', 92),
('app_req', 'STMNT_PERS_GENERAL', 'Personal Statement', 93),
('app_req', 'STMNT_PERS_GRAD_BUEC', 'Personal Statement', 94),
('app_req', 'STMNT_PERS_MC-JURISD', 'Personal Statement', 95),
('app_req', 'STMNT_PERS_OPT', 'Personal Statement', 96),
('app_req', 'STMNT_PERS_UMEP', 'Personal Statement', 97),
('app_req', 'STMNT_PERS_VPHEAD', 'Personal Statement', 98),
('app_req', 'STMNT_PRPSE_SAEX', 'Personal Statement', 99),
('app_req', 'STMNT_PT_RHD', 'Personal Statement', 100),
('app_req', 'BCKGRND_PROF_RHD', 'Professional', 101),
('app_req', 'CERT_AASW', 'Professional', 102),
('app_req', 'CERT_APS', 'Professional', 103),
('app_req', 'CV', 'Professional', 104),
('app_req', 'CV_DOC', 'Professional', 105),
('app_req', 'CV_EVID_PROFPRAC_2', 'Professional', 106),
('app_req', 'EMPLOYER_SUPPORT', 'Professional', 107),
('app_req', 'EMPLOYMENT_HISTORY', 'Professional', 108),
('app_req', 'FELLOW_MED', 'Professional', 109),
('app_req', 'GSBE_QUAL', 'Professional', 110),
('app_req', 'INFO_ARTS_GD_038AB', 'Professional', 111),
('app_req', 'INFO_ARTS_GD_102EU', 'Professional', 112),
('app_req', 'INFO_ARTS_GD_274AB', 'Professional', 113),
('app_req', 'INFO_ARTS_GD_467AA', 'Professional', 114),
('app_req', 'INFO_ARTS_GD_APPLING', 'Professional', 115),
('app_req', 'INFO_ARTS_GD_CULMC', 'Professional', 116),
('app_req', 'INFO_ARTS_GD_CW', 'Professional', 117),
('app_req', 'INFO_ARTS_GD_D01LF', 'Professional', 118),
('app_req', 'INFO_ARTS_GD_SELCOM', 'Professional', 119),
('app_req', 'INFO_HS_NURSE_REG', 'Professional', 120),
('app_req', 'INFO_MDHS_342AA', 'Professional', 121),
('app_req', 'INFO_MDHS_NURS_INT', 'Professional', 122),
('app_req', 'PROF_EXP_CLIN_1Y', 'Professional', 123),
('app_req', 'PROF_EXP_MED_2Y', 'Professional', 124),
('app_req', 'PROF_EXP_MED_2Y_TCH', 'Professional', 125),
('app_req', 'PROF_RADIOLOGY', 'Professional', 126),
('app_req', 'REG_MEDBOARD', 'Professional', 127),
('app_req', 'REG_NURS_DIV1', 'Professional', 128),
('app_req', 'SAMPLE_WRT_RHD_ARTS', 'Professional', 129),
('app_req', 'TSCR_AHW', 'Professional', 130),
('app_req', 'TSCR_BIOSCIHLTH', 'Professional', 131),
('app_req', 'TSCR_GENE', 'Professional', 132),
('app_req', 'TSCR_MBBS_EQUIV', 'Professional', 133),
('app_req', 'TSCR_NURS', 'Professional', 134),
('app_req', 'TSCR_SPCHPTH', 'Professional', 135),
('app_req', 'TSCR_YMH', 'Professional', 136),
('app_req', 'WE_GENERAL', 'Professional', 137),
('app_req', 'WE_GRAD_MC-EMA', 'Professional', 138),
('app_req', 'WE_PROFESSIONAL', 'Professional', 139),
('app_req', 'WE_VOLUNTARY', 'Professional', 140),
('app_req', 'REF_ACAD_RHD', 'Referee', 141),
('app_req', 'REF_ACAD_RHD_ENG', 'Referee', 142),
('app_req', 'REF_ACAD_SA', 'Referee', 143),
('app_req', 'REF_ACAD_SAEX', 'Referee', 144),
('app_req', 'REF_CW_GENERAL', 'Referee', 145),
('app_req', 'REF_CW_POPHEALTH', 'Referee', 146),
('app_req', 'REF_EMPLOYER', 'Referee', 147),
('app_req', 'REF_GC-IRTPPRO', 'Referee', 148),
('app_req', 'REF_PROF_2', 'Referee', 149),
('app_req', 'SCHOL_INTENT_GD', 'Scholarship', 150),
('app_req', 'SCHOL_INTENT_RHD', 'Scholarship', 151),
('app_req', 'SCHOL_INTENT_RHD_INT', 'Scholarship', 152),
('app_req', 'SCHOL_INTENT_UG_LOC', 'Scholarship', 153),
('app_req', 'SCHOL_LHM', 'Scholarship', 154),
('app_req', 'SCHOL_LHM_GC-QA', 'Scholarship', 155),
('app_req', 'ABSTRACT', 'Area of Study', 365),
('app_req', 'DEPT_PROP', 'Area of Study', 157),
('app_req', 'EXT_ORG_RHD_PROP', 'Area of Study', 158),
('app_req', 'HONS_AREA_BMED_DEPT', 'Area of Study', 159),
('app_req', 'HONS_AREA_BMED_SCI', 'Area of Study', 160),
('app_req', 'HONS_AREA_BMED_SPEC', 'Area of Study', 161),
('app_req', 'HONS_AREA_BSC', 'Area of Study', 162),
('app_req', 'HONS_AREA_BSC_DEPT', 'Area of Study', 163),
('app_req', 'HONS_AREA_BUSECO_2', 'Area of Study', 164),
('app_req', 'HONS_AREA_BUSECO_3', 'Area of Study', 165),
('app_req', 'HONS_AREA_MED_DEPT', 'Area of Study', 166),
('app_req', 'HONS_AREA_MSLE_VET', 'Area of Study', 167),
('app_req', 'HONS_BA_PURE_COMB', 'Area of Study', 168),
('app_req', 'HONS_BA_THES_PROP', 'Area of Study', 169),
('app_req', 'HONS_SPEC_BA_1', 'Area of Study', 170),
('app_req', 'HONS_SPEC_BA_2', 'Area of Study', 171),
('app_req', 'HONS_TOPICS_BUSECO', 'Area of Study', 172),
('app_req', 'HONS_TOPIC_PF_1', 'Area of Study', 173),
('app_req', 'HONS_TOPIC_PF_2', 'Area of Study', 174),
('app_req', 'HONS_TOPIC_PF_3', 'Area of Study', 175),
('app_req', 'INFO_ABP_RHD', 'Area of Study', 176),
('app_req', 'INFO_ARTS_GD_SPC', 'Area of Study', 177),
('app_req', 'INFO_ARTS_GD_SPEC_GD', 'Area of Study', 178),
('app_req', 'INFO_ARTS_GD_SPEC_PC', 'Area of Study', 179),
('app_req', 'INFO_DIP_DL_LANG', 'Area of Study', 180),
('app_req', 'INFO_DIP_NEWGEN', 'Area of Study', 181),
('app_req', 'INFO_GC_AHW_SPC', 'Area of Study', 182),
('app_req', 'INFO_MC-ENG_SPC', 'Area of Study', 183),
('app_req', 'INFO_MC-IT_SPC', 'Area of Study', 184),
('app_req', 'INFO_MLM_SUBJ', 'Area of Study', 185),
('app_req', 'INFO_MLM_SUBJ_ALT', 'Area of Study', 186),
('app_req', 'NFO_ARTS_GD_SPEC_PC', 'Area of Study', 187),
('app_req', 'PROP_RHD', 'Area of Study', 188),
('app_req', 'PROP_RHD_ARTS', 'Area of Study', 189),
('app_req', 'PROP_RHD_ECOCOM', 'Area of Study', 190),
('app_req', 'PROP_RHD_NURSSW', 'Area of Study', 191),
('app_req', 'SPCN_MENV', 'Area of Study', 192),
('app_req', 'SPCN_PGDSC', 'Area of Study', 193),
('app_req', 'SPV_GD_SCI', 'Area of Study', 194),
('app_req', 'SPV_GD_SCI_CONT', 'Area of Study', 195),
('app_req', 'SPV_RHD_CONT', 'Area of Study', 196),
('app_req', 'SPV_RHD_PREF', 'Area of Study', 197),
('app_req', 'STUDY_PLAN_D-MATHSC', 'Area of Study', 198),
('app_req', 'STUDY_PLAN_SAEX', 'Area of Study', 199),
('app_req', 'STUDY_PLAN_UMEP', 'Area of Study', 200),
('app_req', 'UMEP_IB_SUB_DET', 'Area of Study', 201),
('app_req', 'UMEP_SUB_MUSIC', 'Area of Study', 202),
('app_req', 'UMEP_SUB_SCI', 'Area of Study', 203),
('app_req', 'UMEP_VCE_SUBJ_DET', 'Area of Study', 204),
('app_req', 'SPONS_UG', 'Sponsor', 205),
('app_req', 'CAP_APP_FORM', 'Supplementary Form', 206),
('app_req', 'INFO_VCAM', 'Supplementary Form', 207),
('app_req', 'INFO_VCAM_ART', 'Supplementary Form', 208),
('app_req', 'INFO_VCAM_CCD', 'Supplementary Form', 209),
('app_req', 'INFO_VCAM_FILMTV', 'Supplementary Form', 210),
('app_req', 'INFO_VCAM_MUSIC', 'Supplementary Form', 211),
('app_req', 'INFO_VCAM_PERFARTS', 'Supplementary Form', 212),
('app_req', 'INFO_VCAM_WILIN', 'Supplementary Form', 213),
('app_req', 'GAMSAT_CW', 'Test Results', 214),
('app_req', 'GAMSAT_CW_MED', 'Test Results', 215),
('app_req', 'GMAT_GRE_CW', 'Test Results', 216),
('app_req', 'GMAT_GRE_RHD', 'Test Results', 217),
('app_req', 'LSAT', 'Test Results', 218),
('app_req', 'MCAT_CW_DENSUR', 'Test Results', 219),
('app_req', 'MCAT_CW_MED', 'Test Results', 220),
('app_req', 'MCAT_GD_SCI', 'Test Results', 221),
('app_req', 'OAT_CW', 'Test Results', 222),
('app_req', 'RES_RQ_RHD', 'Other', 223),
('app_req', 'ADVST_INTENT_MLM', 'Course-Specific', 238),
('app_req', 'AGT', 'Advanced Standing', 236),
('app_req', 'ADVST_INTENT_INT', 'International', 237),
('app_req', 'ABSTRACT', 'Thesis', 367),
('app_req', 'ABSTRACT', 'RHD', 366),
('app_req', 'STUDY_PLAN_SAEX', 'Course-Specific', 241),
('app_req', 'STUDY_PLAN_SAEX', 'SAEX', 242),
('app_req', 'STUDY_PLAN_SAEX', 'Study Plan', 243),
('doc_req', 'EVDNCE', 'Evidence', 244),
('doc_req', 'CAP_APP_FORM', 'Supplementary Form', 245),
('doc_req', 'CAP_APP_FORM', 'Course-Specific', 246),
('doc_req', 'CAP_APP_FORM', 'CAP', 247),
('doc_req', 'CAP_APP_FORM', 'Obsolete', 248),
('doc_req', 'FORM', 'Form', 249),
('doc_req', 'FORM_VCAM_SUPP', 'Form', 250),
('doc_req', 'FORM_PERMISSION', 'Form', 251),
('doc_req', 'FORM_REC_APPROVAL', 'Form', 252),
('doc_req', 'FORM_ADVST', 'Form', 253),
('doc_req', 'FORM_GAM', 'Form', 254),
('doc_req', 'FORM_ADVST', 'Advanced Standing', 255),
('doc_req', 'FORM_GAM', 'Graduate Access', 256),
('doc_req', 'LETTER', 'Letter', 257),
('doc_req', 'LETTER', 'Generic', 258),
('doc_req', 'LETTER_AGENT', 'Letter', 259),
('doc_req', 'LETTER_AGENT', 'Agent', 260),
('app_req', 'ADVST_MENV', 'Course-Specific', 261),
('app_req', 'HONS_AREA_BMED_DEPT', 'Course-Specific', 262),
('app_req', 'HONS_AREA_BMED_SCI', 'Course-Specific', 263),
('app_req', 'HONS_AREA_BMED_SPEC', 'Course-Specific', 264),
('app_req', 'HONS_AREA_BSC', 'Course-Specific', 265),
('app_req', 'HONS_AREA_BSC_DEPT', 'Course-Specific', 266),
('app_req', 'HONS_AREA_BUSECO_2', 'Course-Specific', 267),
('app_req', 'HONS_AREA_BUSECO_3', 'Course-Specific', 268),
('app_req', 'HONS_AREA_MED_DEPT', 'Course-Specific', 269),
('app_req', 'HONS_AREA_BUSECO_3', 'Obsolete', 270),
('app_req', 'HONS_AREA_BUSECO_2', 'Obsolete', 271),
('app_req', 'HONS_AREA_BSC_DEPT', 'Obsolete', 272),
('app_req', 'TSCR_BIOSCIHLTH', 'Course-Specific', 273),
('app_req', 'TSCR_BIOSCIHLTH', 'Acceptance', 274),
('app_req', 'ADVST_MC-JURISD', 'Course-Specific', 275),
('app_req', 'EN_LANG', 'English Language', 276),
('app_req', 'EN_LANG_SAEX', 'Course-Specific', 292),
('app_req', 'EN_LANG_SAEX', 'English Language', 278),
('app_req', 'EN_LANG_SAEX', 'Nested', 291),
('app_req', 'ELP_GD', 'Obsolete', 280),
('app_req', 'ELP_GD_LOCAL', 'Obsolete', 281),
('app_req', 'ELP_GD_SAEX', 'Obsolete', 282),
('app_req', 'ELP_UG', 'Obsolete', 283),
('app_req', 'ELP_UG_LOCAL', 'Obsolete', 284),
('app_req', 'ELP_UG_SAEX', 'Obsolete', 285),
('app_req', 'EN_LANG_OTH', 'Nested', 286),
('app_req', 'EN_LANG_SAEX_OTH', 'Nested', 287),
('app_req', 'EN_LANG_SAEX_OTH', 'English Language', 288),
('app_req', 'EN_LANG_OTH', 'English Language', 289),
('app_req', 'EN_LANG', 'Nested', 290),
('app_req', 'EDUC_TE', 'Educational Background', 293),
('app_req', 'EDUC_TE', 'Multiple Fields', 294),
('app_req', 'ADVST_MC-JURISD', 'Form', 295),
('app_req', 'ADVST_MC-JURISD', 'Supplementary Form', 296),
('app_req', 'AGT', 'International', 297),
('app_req', 'AGT', 'Multiple Fields', 298),
('app_req', 'AGT', 'Letter', 299),
('app_req', 'AGT', 'Link', 300),
('doc_req', 'CERTIFICATION', 'Professional', 301),
('std_cd', 'AR_EN_LANG', 'English Language', 302),
('std_cd', 'UM_AR_GC_AHW_SPC', 'Area of Study', 303),
('std_cd', 'UM_AR_GC_AHW_SPC', 'Course-Specific', 304),
('std_cd', 'AR_EN_LANG_SAEX', 'English Language', 305),
('std_cd', 'AR_EN_LANG_SAEX', 'Course-Specific', 306),
('std_cd', 'AR_EN_LANG_SAEX', 'SAEX', 307),
('std_cd', 'AR_SEMESTER', 'Study Period', 308),
('std_cd', 'UM_AR_BH_BA_COMBINED', 'Area of Study', 309),
('std_cd', 'UM_AR_BH_BA_COMBINED', 'Course-Specific', 311),
('std_cd', 'UM_AR_BH_BA_SPC', 'Area of Study', 312),
('std_cd', 'UM_AR_BH_BA_SPC', 'Course-Specific', 313),
('std_cd', 'UM_AR_BH_BMED_SCI', 'Area of Study', 314),
('std_cd', 'UM_AR_BH_BMED_SCI', 'Course-Specific', 315),
('std_cd', 'UM_AR_ELP_GD', 'English Language', 316),
('std_cd', 'UM_AR_ELP_GD', 'Obsolete', 317),
('std_cd', 'UM_AR_ELP_GD_SAEX', 'English Language', 318),
('std_cd', 'UM_AR_ELP_GD_SAEX', 'Obsolete', 319),
('std_cd', 'UM_AR_ELP_UG', 'English Language', 320),
('std_cd', 'UM_AR_ELP_UG', 'Obsolete', 321),
('std_cd', 'UM_AR_ELP_UG_SAEX', 'English Language', 322),
('std_cd', 'UM_AR_ELP_UG_SAEX', 'Obsolete', 323),
('cnf_em', 'PHYS_GEN_INT', 'Physical Submission', 324),
('cnf_em', 'PHYS_GEN_INT', 'International', 325),
('cnf_em', 'PHYS_MDHS_LOC', 'Physical Submission', 326),
('cnf_em', 'PHYS_MDHS_LOC', 'Course-Specific', 327),
('cnf_em', 'PHYS_MDHS_LOC', 'Domestic', 328),
('cnf_em', 'PHYS_SOCWK_LOC', 'Physical Submission', 329),
('cnf_em', 'PHYS_SOCWK_LOC', 'Domestic', 330),
('cnf_em', 'PHYS_SOCWK_LOC', 'Course-Specific', 331),
('cnf_em', 'SAEX_ALL', 'Course-Specific', 332),
('cnf_em', 'SAEX_ALL', 'SAEX', 333),
('cnf_em', 'SAEX_ALL', 'Domestic', 334),
('cnf_em', 'UMEP_A', 'Course-Specific', 335),
('cnf_em', 'UMEP_A', 'UMEP', 336),
('cnf_em', 'UMEP_ALL', 'Course-Specific', 337),
('cnf_em', 'UMEP_ALL', 'UMEP', 338),
('cnf_em', 'UMEP_ALL', 'Contact Details', 339),
('cnf_em', 'UMEP_B', 'Contact Details', 340),
('cnf_em', 'UMEP_B', 'UMEP', 341),
('cnf_em', 'UMEP_B', 'Course-Specific', 342),
('std_cd', 'UM_AR_UMEP_SCH_BIO', 'UMEP', 343),
('std_cd', 'UM_AR_UMEP_SCH_BIO', 'Area of Study', 344),
('app_req', 'ADVST_INTENT', 'Supplementary Form', 346),
('app_req', 'ADVST_INTENT', 'Link', 347),
('app_req', 'ADVST_INTENT', 'Generic', 348),
('app_req', 'ADVST_INTENT', 'Domestic', 349),
('app_req', 'UMEP_STU', 'Area of Study', 353),
('app_req', 'UMEP_STU', 'Course-Specific', 354),
('app_req', 'UMEP_STU', 'UMEP', 355),
('app_req', 'UMEP_TEACH_PRINCIPAL', 'Supplementary Form', 357),
('app_req', 'CHESSN', 'Link', 358),
('app_req', 'CAP_CURR_APPROVAL', 'CAP', 359),
('app_req', 'CAP_CURR_APPROVAL', 'Letter', 360),
('app_req', 'CAP_APP_FORM', 'CAP', 361),
('app_req', 'CAP_APP_FORM', 'Course-Specific', 362),
('app_req', 'ACCRED_APAC', 'Professional', 368),
('app_req', 'ACCRED_APAC', 'Course-Specific', 369),
('app_req', 'CERT_AASW', 'Link', 370),
('app_req', 'CERT_AASW', 'Course-Specific', 371),
('app_req', 'CAP_FACSCH', 'CAP', 372),
('app_req', 'CAP_FACSCH', 'Course-Specific', 373),
('app_req', 'CAP_FACSCH', 'Area of Study', 374),
('app_req', 'CAP_PURPOSE', 'CAP', 375),
('app_req', 'CAP_PURPOSE', 'Course-Specific', 376),
('app_req', 'CAP_EDUC_UG', 'CAP', 377),
('app_req', 'CAP_EDUC_UG', 'Course-Specific', 378),
('app_req', 'CAP_EDUC_PG', 'CAP', 379),
('app_req', 'CAP_EDUC_PG', 'Course-Specific', 380),
('app_req', 'CAP_CURR_APPROVAL', 'Course-Specific', 381),
('app_req', 'REQ_CW_VETMED', 'Course-Specific', 382),
('app_req', 'REQ_CW_VETMED', 'DVM', 383),
('std_cd', 'UM_AR_DL_LANGUAGES', 'Area of Study', 384),
('std_cd', 'UM_AR_DL_LANGUAGES', 'Course-Specific', 385),
('std_cd', 'UM_AR_CAP_FACSCH', 'CAP', 386),
('std_cd', 'UM_AR_CAP_FACSCH', 'Course-Specific', 387),
('std_cd', 'UM_AR_CAP_FACSCH', 'Area of Study', 388),
('app_req', 'CV_DOC', 'CV', 389),
('app_req', 'CV_EVID_PROFPRAC_2', 'CV', 390),
('app_req', 'CV_EVID_PROFPRAC_2', 'Required Qualification', 391),
('app_req', 'WE_VOLUNTARY', 'Work Experience', 392),
('app_req', 'WE_VOLUNTARY', 'CV', 393),
('app_req', 'WE_PROFESSIONAL', 'CV', 394),
('app_req', 'WE_PROFESSIONAL', 'Work Experience', 395),
('app_req', 'WE_GENERAL', 'Work Experience', 396),
('app_req', 'CV', 'CV', 397),
('app_req', 'CV', 'Work Experience', 398),
('app_req', 'CV_DOC', 'Work Experience', 399),
('app_req', 'CV_EVID_PROFPRAC_2', 'Work Experience', 400),
('std_cd', 'YES_NO_CODE', 'Acceptance', 403),
('std_cd', 'YES_NO_CODE', 'Checklist', 404),
('app_req', 'STMNT_PT_RHD', 'Link', 405),
('app_req', 'STMNT_PT_RHD', 'RHD', 406);

-- --------------------------------------------------------

--
-- Table structure for table `uom_urls`
--

CREATE TABLE IF NOT EXISTS `uom_urls` (
  `rec_type` varchar(10) DEFAULT NULL,
  `rec_cd` varchar(20) DEFAULT NULL,
  `url` text,
  `email` tinyint(1) NOT NULL DEFAULT '0',
  `redirect` tinyint(1) NOT NULL DEFAULT '0',
  `status` int(11) DEFAULT NULL,
  `status_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `check_times` int(10) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM  DEFAULT CHARSET=utf8 AUTO_INCREMENT=52 ;

--
-- Dumping data for table `uom_urls`
--

INSERT INTO `uom_urls` (`rec_type`, `rec_cd`, `url`, `email`, `redirect`, `status`, `status_date`, `id`, `check_times`) VALUES
('app_req', 'UMEP_TEACH_PRINCIPAL', 'http://futurestudents.unimelb.edu.au/info/school-students/extension-program/apply', 0, 0, 200, '2013-07-04 09:34:12', 3, 1),
('app_req', 'ADVST_INTENT', 'http://www.services.unimelb.edu.au', 0, 1, 200, '2013-07-04 14:37:37', 8, 4),
('app_req', 'ADVST_INTENT', 'http://www.futurestudents.unimelb.edu.au/__data/assets/pdf_file/0007/332458/Credit_Advanced_Standing_form.pdf', 0, 1, 200, '2013-07-04 14:37:36', 7, 4),
('app_req', 'ACCRED_APAC', 'http://www.psychologycouncil.org.au/', 0, 0, 200, '2013-07-28 13:12:19', 6, 6),
('app_req', 'AGT', 'http://futurestudents.unimelb.edu.au/contact/overseas_representatives', 0, 0, 200, '2013-07-04 14:14:59', 11, 5),
('app_req', 'CAP_FACSCH', 'http://futurestudents.unimelb.edu.au/courses/single_subject_study/study_areas', 0, 0, 200, '2013-07-04 10:46:29', 12, 4),
('app_req', 'CHESSN', 'http://www.goingtouni.gov.au/Main/Resources/YourCHESSNAndStudentAssistanceRecord/', 0, 0, 301, '2013-07-04 10:53:42', 13, 2),
('app_req', 'EN_LANG', 'http://futurestudents.unimelb.edu.au/admissions/entry-requirements/language-requirements', 0, 0, 200, '2013-07-04 10:54:09', 14, 1),
('app_req', 'ELP_GD', 'http://futurestudents.unimelb.edu.au/admissions/entry-requirements/language-requirements', 0, 0, 200, '2013-07-04 10:54:48', 15, 1),
('app_req', 'ELP_UG', 'http://futurestudents.unimelb.edu.au/admissions/entry-requirements/language-requirements', 0, 0, 200, '2013-07-04 10:54:54', 16, 1),
('app_req', 'ELP_UG_SAEX', 'http://futurestudents.unimelb.edu.au/admissions/entry-requirements/language-requirements', 0, 0, 200, '2013-07-04 10:54:58', 17, 1),
('app_req', 'ELP_UG_LOCAL', 'http://www.futurestudents.unimelb.edu.au/ugrad/apply/english-req.html', 0, 0, 301, '2013-07-04 11:26:37', 18, 2),
('doc_req', 'CAP_APP_FORM', 'http://www.futurestudents.unimelb.edu.au/cap-form', 0, 1, 403, '2013-07-04 13:16:25', 19, 2),
('cnf_em', 'CAP_ALL', '13melb@unimelb.edu.au', 1, 0, NULL, '2013-07-04 11:54:07', 20, 2),
('app_req', 'CHECKLIST_LHM_GC-QA', 'leo.g@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:00:39', 21, 1),
('cnf_em', 'EASTERNPRECINCT_GEN', 'epsc-contact@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:06:05', 22, 1),
('cnf_em', 'GRAD_INT', 'ia-suppdoc@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:08:11', 23, 1),
('cnf_em', 'GRAD_ARTS_CW', 'gshss-admissions@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:08:23', 24, 1),
('cnf_em', 'GRAD_ARTS_CW', 'http://graduate.arts.unimelb.edu.au/admissions/scholarships.html', 0, 0, 200, '2013-07-04 12:17:17', 25, 3),
('cnf_em', 'GRAD_ARTS_CW', 'http://graduate.arts.unimelb.edu.au/', 0, 0, 200, '2013-07-04 12:17:18', 26, 3),
('cnf_em', 'GRAD_ARTS_CW', 'https://prod.ss.unimelb.edu.au/student/S1/eApplications/eAppLog', 0, 0, 404, '2013-07-04 12:17:20', 27, 3),
('cnf_em', 'GRAD_APB_ALL', 'msd-info@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:12:20', 28, 1),
('cnf_em', 'GRAD_BUSECO_ALL', 'gsbe-enquiries@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:17:57', 29, 1),
('cnf_em', 'GRAD_BUSECO_ALL', 'gsbe-research@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:17:57', 30, 1),
('cnf_em', 'GRAD_DENTAL', 'enquiries@dent.unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:18:09', 31, 1),
('cnf_em', 'GRAD_EDU_ALL', 'http://edfac-unimelb.custhelp.com/cgi-bin/edfac_unimelb.cfg/php/enduser/ask.php', 0, 0, 0, '2013-07-04 12:19:25', 32, 2),
('cnf_em', 'GRAD_ENG_ALL', 'http://www.eng.unimelb.edu.au/admissions/', 0, 0, 301, '2013-07-04 12:19:41', 33, 1),
('cnf_em', 'GRAD_HS_NURS', 'http://www.nursing.unimelb.edu.au/files/nursing/Credit_Application_Form.pdf', 0, 1, 404, '2013-07-04 13:10:48', 40, 8),
('cnf_em', 'GRAD_HS_NURS', 'http://www.nursing.unimelb.edu.au/files/nursing/Employer_Support_of_Advanced_Practice_Role_Form.pdf', 0, 1, 404, '2013-07-04 13:10:50', 39, 8),
('cnf_em', 'GRAD_HS_NURS', 'http://www.nursing.unimelb.edu.au/files/nursing/Confirmation_of_Employment_Clinical_Support_Form.pdf', 0, 1, 404, '2013-07-04 13:10:51', 38, 8),
('cnf_em', 'GRAD_HS_NURS', 'nursing-enquiries@unimelb.edu.au', 1, 0, NULL, '2013-07-04 12:20:24', 37, 1),
('cnf_em', 'UG_INT', 'ia-suppdoc@unimelb.edu.au', 1, 0, NULL, '2013-07-04 13:18:42', 41, 1),
('app_req', 'CERT_AASW', 'http://www.aasw.asn.au/membershipinfo/membership-eligibility', 0, 0, 200, '2013-07-28 13:13:50', 42, 1),
('app_req', 'REQ_CW_VETMED', 'https://handbook.unimelb.edu.au/view/current/BIOL10004', 0, 0, 200, '2013-07-31 12:06:01', 43, 1),
('app_req', 'REQ_CW_VETMED', 'https://handbook.unimelb.edu.au/view/current/BIOL10005', 0, 0, 200, '2013-07-31 12:06:03', 44, 1),
('app_req', 'REQ_CW_VETMED', 'https://handbook.unimelb.edu.au/view/current/BCMB20002', 0, 0, 200, '2013-07-31 12:06:05', 45, 1),
('app_req', 'REQ_CW_VETMED', 'https://handbook.unimelb.edu.au/view/current/BIOM20002', 0, 0, 200, '2013-07-31 12:06:06', 46, 1),
('App_Req', 'STMNT_PT_RHD', 'http://cms.services.unimelb.edu.au/scholarships/pgrad/local/available', 0, 1, 200, '2013-09-20 06:50:10', 51, 1),
('app_req', 'RES_RQ_RHD', 'http://www.gradresearch.unimelb.edu.au/current/phdhbk/admission.html#residency', 0, 1, 200, '2013-09-18 08:15:35', 48, 1),
('app_req', 'RES_RQ_RHD', 'http://www.gradresearch.unimelb.edu.au/current/mphilhbk/admission.html#requirements', 0, 1, 200, '2013-09-18 08:15:35', 49, 1),
('app_req', 'RES_RQ_RHD', 'http://www.gradresearch.unimelb.edu.au/current/masters/generichbk/admission.html#requirements', 0, 1, 200, '2013-09-18 08:15:35', 50, 1);

-- --------------------------------------------------------

--
-- Table structure for table `app_doc_req`
--

CREATE TABLE IF NOT EXISTS `app_doc_req` (
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `doc_rqmnt_cd` varchar(20) DEFAULT NULL,
  `online_submit_fg` varchar(1) DEFAULT NULL,
  `physical_submit_fg` varchar(1) DEFAULT NULL,
  UNIQUE KEY `app_doc_rqmnt_cd` (`app_rqmnt_cd`,`doc_rqmnt_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `app_req`
--

CREATE TABLE IF NOT EXISTS `app_req` (
  `app_rqmnt_cd` varchar(20) NOT NULL DEFAULT '',
  `app_rqmnt_descr` varchar(255) DEFAULT NULL,
  `app_rqmnt_full_descr` text,
  `active_fg` varchar(1) DEFAULT NULL,
  `doc_rqmnt_comp_fg` varchar(1) DEFAULT NULL,
  `resp_prompt_fg` varchar(1) DEFAULT NULL,
  `max_number_responses` int(6) DEFAULT NULL,
  `default_number_responses` int(6) DEFAULT NULL,
  `required_number_responses` int(6) DEFAULT NULL,
  `parent_app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `sub_req_crt_grp` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`app_rqmnt_cd`),
  UNIQUE KEY `app_rqmnt_cd` (`app_rqmnt_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `app_req_crt`
--

CREATE TABLE IF NOT EXISTS `app_req_crt` (
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `crit_type` varchar(20) DEFAULT NULL,
  `crit_name` varchar(60) DEFAULT NULL,
  `crit_op` varchar(10) DEFAULT NULL,
  `crit_descr` varchar(50) DEFAULT NULL,
  `crit_code` varchar(30) DEFAULT NULL,
  `crit_value` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `app_req_std_cd`
--

CREATE TABLE IF NOT EXISTS `app_req_std_cd` (
  `app_rqmnt_cd` varchar(40) DEFAULT NULL,
  `code_type` varchar(30) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `cnf_em`
--

CREATE TABLE IF NOT EXISTS `cnf_em` (
  `eap_rspns_cd` varchar(20) NOT NULL DEFAULT '',
  `eap_rspns_descr` varchar(255) DEFAULT NULL,
  `eap_rspns_text` text,
  PRIMARY KEY (`eap_rspns_cd`),
  UNIQUE KEY `eap_rspns_cd` (`eap_rspns_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `cnf_em_crt`
--

CREATE TABLE IF NOT EXISTS `cnf_em_crt` (
  `eap_rspns_cd` varchar(20) DEFAULT NULL,
  `crit_type` varchar(20) DEFAULT NULL,
  `crit_name` varchar(60) DEFAULT NULL,
  `crit_op` varchar(10) DEFAULT NULL,
  `crit_descr` varchar(50) DEFAULT NULL,
  `crit_code` varchar(30) DEFAULT NULL,
  `crit_value` varchar(100) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `doc_req`
--

CREATE TABLE IF NOT EXISTS `doc_req` (
  `doc_rqmnt_cd` varchar(20) NOT NULL DEFAULT '',
  `doc_rqmnt_descr` varchar(255) DEFAULT NULL,
  `doc_rqmnt_full_descr` text,
  `stu_doc_type_cd` varchar(20) DEFAULT NULL,
  `doc_no_prompt_fg` varchar(1) DEFAULT NULL,
  `doc_no_prompt_descr` varchar(255) DEFAULT NULL,
  `issue_dt_prompt_fg` varchar(1) DEFAULT NULL,
  `issue_dt_prompt_descr` varchar(255) DEFAULT NULL,
  `expy_dt_prompt_fg` varchar(1) DEFAULT NULL,
  `expy_dt_prompt_descr` varchar(255) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  `add_info_link_src_cd` varchar(3) DEFAULT NULL,
  `add_info_link_name` varchar(255) DEFAULT NULL,
  `add_info_url_txt` varchar(1978) DEFAULT NULL,
  `add_info_dir_code_type` varchar(20) DEFAULT NULL,
  `add_info_dir_code` varchar(8) DEFAULT NULL,
  `add_info_file_name` varchar(22) DEFAULT NULL,
  `add_info_link_lbl_disp_fg` varchar(1) DEFAULT NULL,
  `add_info_link_lbl_txt` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`doc_rqmnt_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `inst_app_req`
--

CREATE TABLE IF NOT EXISTS `inst_app_req` (
  `app_rqmnt_cd` varchar(20) NOT NULL DEFAULT '',
  `seq_no` int(8) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`app_rqmnt_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `inst_cnf_em`
--

CREATE TABLE IF NOT EXISTS `inst_cnf_em` (
  `eap_rspns_cd` varchar(20) NOT NULL DEFAULT '',
  `seq_no` varchar(20) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`eap_rspns_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_app_req`
--

CREATE TABLE IF NOT EXISTS `spk_app_req` (
  `spk_cd` varchar(20) DEFAULT NULL,
  `spk_ver_no` int(1) DEFAULT NULL,
  `spk_id` varchar(20) DEFAULT NULL,
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `seq_no` int(6) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_cat`
--

CREATE TABLE IF NOT EXISTS `spk_cat` (
  `spk_cat_type_cd` varchar(3) NOT NULL DEFAULT '',
  `spk_cat_type_desc` varchar(60) DEFAULT NULL,
  `spk_cat_lvl_cd` varchar(2) DEFAULT NULL,
  `study_type_cd` varchar(4) DEFAULT NULL,
  `self_apply_fg` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`spk_cat_type_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_cat_app_req`
--

CREATE TABLE IF NOT EXISTS `spk_cat_app_req` (
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `spk_cat_type_cd` varchar(3) DEFAULT NULL,
  `seq_no` int(9) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  UNIQUE KEY `spk_cat_app_req` (`app_rqmnt_cd`,`spk_cat_type_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_cat_cnf_em`
--

CREATE TABLE IF NOT EXISTS `spk_cat_cnf_em` (
  `eap_rspns_cd` varchar(20) DEFAULT NULL,
  `spk_cat_type_cd` varchar(3) DEFAULT NULL,
  `seq_no` varchar(20) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  UNIQUE KEY `spk_cat_cnf_em` (`spk_cat_type_cd`,`eap_rspns_cd`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Stand-in structure for view `spk_cat_inh_app_req`
--
CREATE TABLE IF NOT EXISTS `spk_cat_inh_app_req` (
  `app_rqmnt_cd` varchar(20)
  ,`spk_cat_type_cd` varchar(3)
  ,`seq_no` int(11)
  ,`active_fg` varchar(1)
  ,`inherit_from` varchar(7)
);
-- --------------------------------------------------------

--
-- Table structure for table `spk_cd`
--

CREATE TABLE IF NOT EXISTS `spk_cd` (
  `spk_no` int(5) DEFAULT NULL,
  `spk_cd` varchar(10) DEFAULT NULL,
  `spk_cat_type_cd` varchar(3) DEFAULT NULL,
  `spk_full_title` varchar(72) DEFAULT NULL,
  `self_apply_fg` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_cnf_em`
--

CREATE TABLE IF NOT EXISTS `spk_cnf_em` (
  `spk_cd` varchar(20) DEFAULT NULL,
  `spk_ver_no` int(1) DEFAULT NULL,
  `spk_id` varchar(20) DEFAULT NULL,
  `eap_rspns_cd` varchar(20) DEFAULT NULL,
  `seq_no` varchar(20) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `spk_ver`
--

CREATE TABLE IF NOT EXISTS `spk_ver` (
  `spk_no` int(5) DEFAULT NULL,
  `spk_cd` varchar(10) DEFAULT NULL,
  `spk_ver_no` int(1) DEFAULT NULL,
  `spk_id` varchar(12) DEFAULT NULL,
  `spk_cat_type_cd` varchar(3) DEFAULT NULL,
  `spk_stage_cd` varchar(2) DEFAULT NULL,
  `spk_full_title` varchar(72) DEFAULT NULL,
  `self_apply_fg` varchar(1) DEFAULT NULL,
  UNIQUE KEY `spk_cd_ver` (`spk_no`,`spk_cd`,`spk_ver_no`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `std_cd`
--

CREATE TABLE IF NOT EXISTS `std_cd` (
  `code_type` varchar(30) NOT NULL DEFAULT '',
  `code_type_descr` varchar(40) DEFAULT NULL,
  `maint_by_code` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`code_type`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `std_cd_val`
--

CREATE TABLE IF NOT EXISTS `std_cd_val` (
  `code_type` varchar(26) DEFAULT NULL,
  `code_id` varchar(8) DEFAULT NULL,
  `code_descr` varchar(60) DEFAULT NULL,
  `active_fg` varchar(1) DEFAULT NULL,
  `seq_no` int(4) DEFAULT NULL,
  `maint_by_code` varchar(1) DEFAULT NULL,
  UNIQUE KEY `std_code_val` (`code_type`,`code_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sub_req_crt`
--

CREATE TABLE IF NOT EXISTS `sub_req_crt` (
  `app_subreq_crit_id` int(10) NOT NULL DEFAULT '0',
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `sub_req_crt_grp` int(10) DEFAULT NULL,
  `response_field_id` int(10) DEFAULT NULL,
  `crit_op` varchar(10) DEFAULT NULL,
  `crit_value` varchar(2048) DEFAULT NULL,
  PRIMARY KEY (`app_subreq_crit_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `usr_fld`
--

CREATE TABLE IF NOT EXISTS `usr_fld` (
  `app_rqmnt_cd` varchar(20) DEFAULT NULL,
  `label` varchar(255) DEFAULT NULL,
  `data_type` varchar(2) DEFAULT NULL,
  `watermark` varchar(255) DEFAULT NULL,
  `hint_text` varchar(255) DEFAULT NULL,
  `skin_id` varchar(255) DEFAULT NULL,
  `code_type` varchar(30) DEFAULT NULL,
  `maximum_length` int(4) DEFAULT NULL,
  `mandatory_fg` varchar(1) DEFAULT NULL,
  `seq_no` int(1) DEFAULT NULL,
  `response_field_id` int(10) NOT NULL DEFAULT '0',
  PRIMARY KEY (`response_field_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure for view `spk_cat_inh_app_req`
--
DROP TABLE IF EXISTS `spk_cat_inh_app_req`;

CREATE ALGORITHM=TEMPTABLE DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `spk_cat_inh_app_req` AS select `inst_app_req`.`app_rqmnt_cd` AS `app_rqmnt_cd`,`spk_cat`.`spk_cat_type_cd` AS `spk_cat_type_cd`,`inst_app_req`.`seq_no` AS `seq_no`,`inst_app_req`.`active_fg` AS `active_fg`,'inst' AS `inherit_from` from (`inst_app_req` left join `spk_cat` on((1 = 1))) where (not(exists(select 1 from `spk_cat_app_req` where ((`spk_cat_app_req`.`active_fg` = 'N') and (`spk_cat_app_req`.`spk_cat_type_cd` = `spk_cat`.`spk_cat_type_cd`) and (`spk_cat_app_req`.`app_rqmnt_cd` = `inst_app_req`.`app_rqmnt_cd`))))) union select `spk_cat_app_req`.`app_rqmnt_cd` AS `app_rqmnt_cd`,`spk_cat_app_req`.`spk_cat_type_cd` AS `spk_cat_type_cd`,`spk_cat_app_req`.`seq_no` AS `seq_no`,`spk_cat_app_req`.`active_fg` AS `active_fg`,'spk_cat' AS `inherit_from` from `spk_cat_app_req`;
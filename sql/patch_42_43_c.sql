# patch_42_43_c
#
# title: Probe info type
#
# description:
# Add PROBE to info_type enum

ALTER TABLE xref CHANGE COLUMN info_type info_type ENUM('PROJECTION', 'MISC', 'DEPENDENT', 'DIRECT', 'SEQUENCE_MATCH', 'INFERRED_PAIR', 'PROBE');


# patch identifier
INSERT INTO meta (meta_key, meta_value) VALUES ('patch', 'patch_42_43_c.sql|info_type_probe');
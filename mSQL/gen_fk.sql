SELECT   CONCAT('ALTER TABLE',' ',tc.table_schema,'.',tc.table_name,' '
               ,'ADD CONSTRAINT',' fk_',tc.constraint_name,' '
               ,'FOREIGN KEY (',kcu.column_name,')',' '
               ,'REFERENCES',' ',kcu.referenced_table_schema,'.',kcu.referenced_table_name,' '
               ,'(',kcu.referenced_column_name,');') AS script
FROM     information_schema.table_constraints tc JOIN information_schema.key_column_usage kcu
ON       tc.constraint_name = kcu.constraint_name
AND      tc.constraint_schema = kcu.constraint_schema
WHERE    tc.constraint_type = 'foreign key'
AND      tc.table_name = 'l10n_text_resource'
AND 	tc.table_schema = 'ftbint3'
ORDER BY tc.TABLE_NAME
,        kcu.column_name
;



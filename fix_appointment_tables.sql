CREATE OR REPLACE FUNCTION fix_appointment_tables() RETURNS bool LANGUAGE PLPGSQL SECURITY DEFINER AS $$
DECLARE
    tbl_name text;
BEGIN
    FOR tbl_name IN
        SELECT split_part(c_location, '/', 5) FROM sogo_folder_info WHERE c_folder_type = 'Appointment'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || tbl_name || '_biu on "public"."' || tbl_name || '";';
        EXECUTE 'CREATE TRIGGER ' || tbl_name || '_biu BEFORE INSERT OR UPDATE ON ' || tbl_name || ' FOR EACH ROW EXECUTE PROCEDURE fix_appointment();';
    END LOOP;
    
    FOR tbl_name IN
        SELECT split_part(c_quick_location, '/', 5) FROM sogo_folder_info WHERE c_folder_type = 'Appointment'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || tbl_name || '_biu on "public"."' || tbl_name || '";';
        EXECUTE 'CREATE TRIGGER ' || tbl_name || '_biu BEFORE INSERT OR UPDATE ON ' || tbl_name || ' FOR EACH ROW EXECUTE PROCEDURE fix_appointment_quick();';
    END LOOP;

    RETURN true; 
END;
$$;

SELECT fix_appointment_tables();

DROP FUNCTION fix_appointment_tables();

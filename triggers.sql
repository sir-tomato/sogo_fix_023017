CREATE OR REPLACE FUNCTION fix_appointment() RETURNS TRIGGER LANGUAGE PLPGSQL SECURITY DEFINER AS $$
BEGIN
    IF (NEW.c_content LIKE '%TZOFFSETFROM:+023017%' OR NEW.c_content LIKE '%TZOFFSETFROM:+023017%') THEN
        NEW.c_content = REGEXP_REPLACE(NEW.c_content, '023017', '0300', 'g');
    END IF;
    RETURN NEW; 
END;
$$;

CREATE OR REPLACE FUNCTION fix_appointment_quick() RETURNS TRIGGER LANGUAGE PLPGSQL SECURITY DEFINER AS $$
BEGIN
    IF (NEW.c_startdate % 60 != 0) THEN
        NEW.c_startdate = NEW.c_startdate - 1783;
        NEW.c_enddate = NEW.c_enddate - 1783;      
    END IF;
    RETURN NEW; 
END;
$$;

CREATE OR REPLACE FUNCTION on_create_table_func() RETURNS event_trigger LANGUAGE plpgsql AS $$
DECLARE
    tbl_name TEXT;
    c_location_ TEXT;  
BEGIN
    SELECT objid::regclass::text INTO tbl_name FROM pg_event_trigger_ddl_commands();

    SELECT c_location INTO c_location_ FROM sogo_folder_info WHERE c_location LIKE '%' || tbl_name AND c_folder_type = 'Appointment';
    IF (c_location_ IS NOT NULL) THEN
        EXECUTE 'CREATE TRIGGER ' || tbl_name || '_biu BEFORE INSERT OR UPDATE ON ' || tbl_name || ' FOR EACH ROW EXECUTE PROCEDURE fix_appointment();';
    END IF;

    SELECT c_location INTO c_location_ FROM sogo_folder_info WHERE c_quick_location LIKE '%' || tbl_name AND c_folder_type = 'Appointment';
    IF (c_location_ IS NOT NULL) THEN
        EXECUTE 'CREATE TRIGGER ' || tbl_name || '_biu BEFORE INSERT OR UPDATE ON ' || tbl_name || ' FOR EACH ROW EXECUTE PROCEDURE fix_appointment_quick();';
    END IF;
END;
$$;

-- FOR THIS NEED DATABASE OWNER
CREATE EVENT TRIGGER on_create_table ON ddl_command_end WHEN TAG IN ('CREATE TABLE') EXECUTE PROCEDURE on_create_table_func();
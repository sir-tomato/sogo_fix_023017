How to use:

1. Add trigger functions. Attention - the last request must be performed from the superuser (CREATE EVENT TRIGGER on_create_table ON ddl_command_end ...)

psql -f triggers.sql <db_name=sogo>

2. If SOGo has been in use for a while - add triggers to existing tables.

psql -f fix_appointment_tables.sql <db_name=sogo>

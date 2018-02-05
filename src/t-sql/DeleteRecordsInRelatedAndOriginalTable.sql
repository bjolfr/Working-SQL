declare @key INT = NULL;
declare _cursor CURSOR FOR 
	select GO_KEY from GrntProp 
	where GO_ADDUKEY = 12001946 order by GO_KEY desc;

open _cursor;
fetch next from _cursor into @key;

while @@FETCH_STATUS = 0
begin
	if exists(select gp_key from GrntProperty where GP_GOKEY = @key)
		delete from GrntProperty where GP_GOKEY = @key;
	if exists(select gn_key from Grnt2Contact where GN_GOKEY = @key)
		delete from Grnt2Contact where GN_GOKEY = @key;
	if exists(select gs_key from GrntStep where GS_GOKEY = @key)
		delete from GrntStep where GS_GOKEY = @key;
	if exists(select ng_key from NOTE_GR where NG_GOKEY = @key)
		delete from NOTE_GR where NG_GOKEY = @key;
	delete from GrntProp where GO_KEY = @key;
	fetch next from _cursor into @key;
end;

close _cursor;
deallocate _cursor;
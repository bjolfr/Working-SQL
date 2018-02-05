IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].UDF_GetChildren') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
	BEGIN 
		PRINT 'Dropping Procedure [dbo].UDF_GetChildren'
		DROP FUNCTION dbo.UDF_GetChildren
		PRINT 'Done.'
	END 
GO

PRINT 'Creating function [dbo].UDF_GetChildren'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION dbo.UDF_GetChildren(@hid hierarchyId)
RETURNS XML
WITH RETURNS NULL ON NULL INPUT 
BEGIN 
RETURN (
	SELECT GPC_HID as "@hid"
		  ,GPC_Description as "@name"
		  ,(SELECT P.GPC_Description as "@prop"
				  ,D.GCD_Value as "@value"
			FROM GPConfig AS O
				LEFT JOIN GPConfigDetails AS D on GPC_KEY = GCD_GPCKEY
				LEFT JOIN GPConfig AS P on P.GPC_KEY = GCD_Property
			WHERE GCD_GPCKEY = T1.GPC_Key ORDER BY O.GPC_HID FOR XML PATH, TYPE) AS props
		  ,CASE WHEN @hid = GPC_HID.GetAncestor(1) AND GPC_HID <> @hid THEN dbo.udf_GetChildren(GPC_HID) END
	FROM GPConfig T1
	WHERE T1.GPC_HID.IsDescendantOf(@hid) = 1 AND GPC_HID.GetAncestor(1) = @hid
	FOR XML PATH, TYPE
);
END
GO

GRANT EXECUTE ON [dbo].UDF_GetChildren to [uja-fed\listuser];
GRANT EXECUTE ON [dbo].UDF_GetChildren TO [ExecRole];
PRINT 'Done.'
GO
-- Create temporary tables that capture instance group assignments based on IG *name*
CREATE TABLE tmp_organization_instancegroup_name_map
AS
    SELECT organization_id, name, position
    FROM main_organizationinstancegroupmembership, main_instancegroup
    WHERE main_organizationinstancegroupmembership.instancegroup_id=main_instancegroup.id;

CREATE TABLE tmp_jobtemplate_instancegroup_name_map
AS
    SELECT unifiedjobtemplate_id, name, position
    FROM main_unifiedjobtemplateinstancegroupmembership, main_instancegroup
    WHERE main_unifiedjobtemplateinstancegroupmembership.instancegroup_id=main_instancegroup.id;

CREATE TABLE tmp_inventory_instancegroup_name_map
AS
    SELECT inventory_id, name, position
    FROM main_inventoryinstancegroupmembership, main_instancegroup
    WHERE main_inventoryinstancegroupmembership.instancegroup_id=main_instancegroup.id;

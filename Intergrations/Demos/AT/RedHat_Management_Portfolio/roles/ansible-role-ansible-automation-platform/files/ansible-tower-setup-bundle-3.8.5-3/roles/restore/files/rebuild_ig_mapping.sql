-- Clear old instance group mappings
DELETE FROM main_organizationinstancegroupmembership;
DELETE FROM main_unifiedjobtemplateinstancegroupmembership;
DELETE FROM main_inventoryinstancegroupmembership;

-- Build new mappings based on instance group names
INSERT INTO main_organizationinstancegroupmembership (instancegroup_id, organization_id, position)
    SELECT main_instancegroup.id, organization_id, position
    FROM tmp_organization_instancegroup_name_map, main_instancegroup
    WHERE tmp_organization_instancegroup_name_map.name = main_instancegroup.name;

INSERT INTO main_unifiedjobtemplateinstancegroupmembership (instancegroup_id, unifiedjobtemplate_id, position)
    SELECT main_instancegroup.id, unifiedjobtemplate_id, position
    FROM tmp_jobtemplate_instancegroup_name_map, main_instancegroup
    WHERE tmp_jobtemplate_instancegroup_name_map.name = main_instancegroup.name;

INSERT INTO main_inventoryinstancegroupmembership (instancegroup_id, inventory_id, position)
    SELECT main_instancegroup.id, inventory_id, position
    FROM tmp_inventory_instancegroup_name_map, main_instancegroup
    WHERE tmp_inventory_instancegroup_name_map.name = main_instancegroup.name;

-- Remove temp mapping tables
DROP TABLE tmp_organization_instancegroup_name_map;
DROP TABLE tmp_jobtemplate_instancegroup_name_map;
DROP TABLE tmp_inventory_instancegroup_name_map;

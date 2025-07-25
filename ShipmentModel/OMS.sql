CREATE DATABASE shipmentData;
USE shipmentData;

-- Table: Shipment (Main Fulfillment Header)
CREATE TABLE Shipment (
    shipment_id VARCHAR(20) PRIMARY KEY, 
    primary_order_id VARCHAR(20),
    primary_ship_group_seq_id VARCHAR(20),
    status_id VARCHAR(20),              -- Shipment Status (e.g., SHIPMENT_SHIPPED, SHIPMENT_DELIVERED)
    shipment_type_id VARCHAR(20),       -- e.g., SALES_SHIPMENT
    tracking_number VARCHAR(50),
    carrier_party_id VARCHAR(20),       -- Party ID of the shipping provider (FedEx, etc.)
    shipment_method_type_id VARCHAR(20),-- Air, ground, same-day, etc.
    origin_contact_mech_id VARCHAR(20),
    estimated_ship_date DATE,
    estimated_delivery_date DATE,
    actual_ship_date DATE,
    actual_delivery_date DATE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table: ShipmentItem (Each item in Shipment)
CREATE TABLE ShipmentItem (
    shipment_item_seq_id VARCHAR(20),   -- Sequence ID for the item
    shipment_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity DECIMAL(18,2),
    PRIMARY KEY (shipment_id, shipment_item_seq_id),
    FOREIGN KEY (shipment_id) REFERENCES Shipment(shipment_id)
);

CREATE TABLE ShipmentPackage (
    shipmentId VARCHAR(20),
    shipmentPackageSeqId VARCHAR(20),
    boxTypeId VARCHAR(20),
    dateCreated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    weight DECIMAL(12, 4),
    weightUomId VARCHAR(20),
    dimensionUomId VARCHAR(20),
    height DECIMAL(12, 4),
    width DECIMAL(12, 4),
    depth DECIMAL(12, 4),
    trackingCode VARCHAR(100),
    packageName VARCHAR(255),
    PRIMARY KEY (shipmentId, shipmentPackageSeqId),
    FOREIGN KEY (shipmentId) REFERENCES Shipment(shipmentId)
);

CREATE TABLE ShipmentRouteSegment (
    shipmentId VARCHAR(20),
    shipmentRouteSegmentId VARCHAR(20),
    carrierPartyId VARCHAR(20),
    originFacilityId VARCHAR(20),
    destFacilityId VARCHAR(20),
    originContactMechId VARCHAR(20),
    destContactMechId VARCHAR(20),
    shipmentMethodTypeId VARCHAR(20),
    carrierServiceStatusId VARCHAR(20),
    statusId VARCHAR(20),
    estimatedStartDate TIMESTAMP,
    estimatedArrivalDate TIMESTAMP,
    PRIMARY KEY (shipmentId, shipmentRouteSegmentId),
    FOREIGN KEY (shipmentId) REFERENCES Shipment(shipmentId)
);

CREATE TABLE ShipmentPackageRouteSegment (
    shipmentId VARCHAR(20),
    shipmentPackageSeqId VARCHAR(20),
    shipmentRouteSegmentId VARCHAR(20),
    boxNumber VARCHAR(20),
    trackingCode VARCHAR(100),
    PRIMARY KEY (shipmentId, shipmentPackageSeqId, shipmentRouteSegmentId),
    FOREIGN KEY (shipmentId, shipmentPackageSeqId) REFERENCES ShipmentPackage(shipmentId, shipmentPackageSeqId),
    FOREIGN KEY (shipmentId, shipmentRouteSegmentId) REFERENCES ShipmentRouteSegment(shipmentId, shipmentRouteSegmentId)
);

-- Table: InventoryItem (Stock item at facility)
CREATE TABLE InventoryItem (
    inventory_item_id VARCHAR(20) PRIMARY KEY,
    product_id VARCHAR(20),
    inventory_item_type_id VARCHAR(20),
    partyId VARCHAR(20),
    statusId VARCHAR(20),
    facility_id VARCHAR(20),
    quantity_on_hand_total DECIMAL(18,2),
    available_to_promise_total DECIMAL(18,2),
    old_quantity_on_hand DECIMAL(18,2),
    old_available_to_promise_total DECIMAL(18,2),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table: ItemIssuance (Issued items for shipment)
-- --------------------------------------------
CREATE TABLE ItemIssuance (
    item_issuance_id VARCHAR(20) PRIMARY KEY,
    shipment_id VARCHAR(20),                 
    shipment_item_seq_id VARCHAR(20),         
    order_id VARCHAR(20),                     
    order_item_seq_id VARCHAR(20),            
    inventory_item_id VARCHAR(20),            
    product_id VARCHAR(20),                   
    issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    quantity DECIMAL(18,2),                  
    facility_id VARCHAR(20),                 
    FOREIGN KEY (shipment_id) REFERENCES Shipment(shipment_id),
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem(inventory_item_id)
);

-- Table: InventoryItemDetail (Adjustments)
CREATE TABLE InventoryItemDetail (
    inventory_item_detail_id VARCHAR(20) PRIMARY KEY,
    inventory_item_id VARCHAR(20),
    shipment_id VARCHAR(20),
    order_id VARCHAR(20),
    quantity_on_hand_diff DECIMAL(18,2), -- Quantity deducted or added
    available_to_promise_diff DECIMAL(18,2),
    reason ENUM('SHIPMENT','RETURN','ADJUSTMENT'),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (inventory_item_id) REFERENCES InventoryItem(inventory_item_id),
    FOREIGN KEY (shipment_id) REFERENCES Shipment(shipment_id)
);

CREATE TABLE OrderShipment (
    orderId VARCHAR(20),
    orderItemSeqId VARCHAR(20),
    shipmentId VARCHAR(20),
    shipmentItemSeqId VARCHAR(20),
    quantity DECIMAL(18, 4),
    PRIMARY KEY (orderId, orderItemSeqId, shipmentId, shipmentItemSeqId),
    FOREIGN KEY (orderId) REFERENCES OrderHeader(orderId),
    FOREIGN KEY (shipmentId) REFERENCES Shipment(shipmentId)
);

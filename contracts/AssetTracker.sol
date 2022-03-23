// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;


contract AssetTracker {
    string id;
 
    function setId(string memory serial) public {
          id = serial;
    }
 
    function getId() public view returns (string memory) {
          return id;
    }

    struct Asset {
    string name;
    string description;
    uint cost;
    uint quantity;
    string manufacturer;
    string customer;
    string addressFrom;
    string addressTo;
    bool initialized;    
    bool arrived;
}

mapping(string  => Asset) private assetStore;


mapping(address => mapping(string => bool)) private walletStore;



event AssetCreate(address account, string uuid,uint cost ,uint quantity ,string manufacturer,string customer,string addressFrom,string addressTo);
event RejectCreate(address account, string uuid, string message);
event AssetTransfer(address from, address to, string uuid);
event RejectTransfer(address from, address to, string uuid, string message);

function createAsset(string memory name, string memory description, string memory uuid,uint cost,uint quantity, string memory manufacturer,string memory customer ,string memory addressFrom,string memory addressTo) public {
 
    if(assetStore[uuid].initialized) {
        emit RejectCreate(msg.sender, uuid, "Asset with this UUID already exists.");
        return;
      }
 
      assetStore[uuid] = Asset(name, description,cost,quantity,manufacturer,customer,addressFrom,addressTo,true,false);
      walletStore[msg.sender][uuid] = true;
      emit AssetCreate(msg.sender, uuid,cost,quantity,manufacturer,customer,addressFrom,addressTo);
}



function transferAsset(address to, string memory uuid) public{
 
    if(!assetStore[uuid].initialized) {
        emit  RejectTransfer(msg.sender, to, uuid, "No asset with this UUID exists");
        return;
    }
 
    if(!walletStore[msg.sender][uuid]) {
        emit RejectTransfer(msg.sender, to, uuid, "Sender does not own this asset.");
        return;
    }
 
    walletStore[msg.sender][uuid] = false;
    walletStore[to][uuid] = true;
    emit AssetTransfer(msg.sender, to, uuid);
}

function getAssetByUUID(string memory uuid) public view returns (string memory, string memory,string memory,string memory,string memory,string memory,bool arrived) {
 
    return (assetStore[uuid].name,assetStore[uuid].description,assetStore[uuid].manufacturer,assetStore[uuid].customer,assetStore[uuid].addressFrom,assetStore[uuid].addressTo,assetStore[uuid].arrived);
    
}

 function getItemByUUID(string memory uuid) public view returns(uint cost,uint quantity){
        return (assetStore[uuid].cost,assetStore[uuid].quantity);
}

function isOwnerOf(address owner, string memory uuid) public view returns (bool) {
 
    if(walletStore[owner][uuid]) {
        return true;
    }
 
    return false;
}

//consumer end 

function Arrived(string memory uuid) public { 
   assetStore[uuid].arrived=true;
}


}


# CrowdFund Smart Contract

This is a simple Ethereum smart contract called `CrowdFund` that enables users to create crowdfunding campaigns, donate to these campaigns, and view details about campaigns and their donors. It is written in Solidity, the programming language used for Ethereum smart contracts.

## Table of Contents

- [Smart Contract Overview](#smart-contract-overview)
- [Functions](#functions)
  - [createCampaign](#createcampaign)
  - [donate](#donate)
  - [getCampaigns](#getcampaigns)
  - [getDonators](#getdonators)
- [License](#license)

## Smart Contract Overview

The `CrowdFund` smart contract allows users to create crowdfunding campaigns with the following attributes:

- `owner`: The Ethereum address of the campaign creator.
- `title`: The title of the campaign.
- `description`: A brief description of the campaign.
- `target`: The fundraising goal in Ether.
- `amountRaised`: The total amount of Ether raised in the campaign.
- `deadline`: The deadline for the campaign in Unix timestamp format.
- `image`: A string representing an image associated with the campaign.
- `donors`: An array of Ethereum addresses of donors to the campaign.
- `donations`: An array of corresponding donation amounts in Ether.

The contract also maintains a mapping of campaign IDs to the campaign structure, allowing for multiple crowdfunding campaigns to coexist.

## Functions

### createCampaign

This function allows users to create a new crowdfunding campaign. It requires the following parameters:

- `_owner`: The Ethereum address of the campaign creator.
- `_title`: The title of the campaign.
- `_description`: A brief description of the campaign.
- `_target`: The fundraising goal in Ether.
- `_deadline`: The deadline for the campaign in Unix timestamp format.
- `_image`: A string representing an image associated with the campaign.

This function returns the campaign's unique identifier.

```solidity
function createCampaign(
    address _owner,
    string memory _title,
    string memory _description,
    uint256 _target,
    uint256 _deadline,
    string memory _image
) public returns (uint256);
```

### donate

This function allows users to make a donation to an existing campaign. It requires the `id` of the campaign to which the donation should be made. The user sends Ether with this function, and the contract records the donation.

```solidity
function donate(uint256 _id) public payable;
```

### getCampaigns

This function allows users to retrieve a list of all the campaigns that have been created. It returns an array of campaign structures, each containing information about a specific campaign.

```solidity
function getCampaigns() public view returns (Campaign[] memory);
```

### getDonators

This function allows users to retrieve a list of donors and their corresponding donation amounts for a specific campaign. It takes the `id` of the campaign as input and returns arrays of donor addresses and donation amounts.

```solidity
function getDonators(uint256 _id) public view returns (address[] memory, uint256[] memory);
```

## License

This smart contract is released under the [UNLICENSED](https://spdx.org/licenses/UNLICENSED.html) license, meaning it is essentially in the public domain with no restrictions on its use. You are free to use, modify, and distribute this code as you see fit. Please proceed with caution and ensure that you understand the implications of using this code for your specific use case.

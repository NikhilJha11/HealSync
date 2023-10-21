// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract CrowdFund {
    //Structure of Campaign with all variables
    struct Campaign {
        address owner;
        string title;
        string description;
        uint256 target;
        uint256 amountRaised;
        uint256 deadline;
        string image;
        uint256[] donors;
        uint256[] donations;
    }
    mapping(uint256 => Campaign) campaigns;
    uint256 public numberOfCampaigns = 0;

    //Function to create the campaign
    function createCampaign(
        address _owner,
        string memory _title,
        string memory _description,
        uint256 _target,
        uint256 _deadline,
        string memory _image
    ) public returns (uint256) {
        Campaign storage campaign = campaigns[numberOfCampaigns];

        require(
            campaign.deadline < block.timestamp,
            "The campaign date must be set to sometime in the future."
        );

        campaign.owner = _owner;
        campaign.title = _title;
        campaign.description = _description;
        campaign.deadline = _deadline;
        campaign.target = _target;
        campaign.image = _image;

        numberOfCampaigns++;
        return (numberOfCampaigns - 1);
    }

    //Function to donate to the campaign
    function donate(uint256 _id) public payable {
        uint256 amount = msg.value;
        Campaign storage campaign = campaigns[_id];

        (bool sent, ) = payable(campaign.owner).call{value: amount}("");

        if (sent) {
            campaign.amountRaised = campaign.amountRaised + amount;
        }
    }

    //Function to get a list of all the campaigns
    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory campaignList = new Campaign[](numberOfCampaigns);
        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            campaignList[i] = item;
        }
        return campaignList;
    }

    //Function to get a list of donors
    function getDonators(
        uint256 _id
    ) public view returns (address[] memory, uint256[] memory) {
        Campaign storage campaign = campaigns[_id];
        address[] memory memoryDonors = new address[](campaign.donors.length);
        uint256[] memory memoryDonations = new uint256[](
            campaign.donations.length
        );

        for (uint i = 0; i < campaign.donors.length; i++) {
            //memoryDonors[i] = campaign.donors[i];
            memoryDonations[i] = campaign.donations[i];
        }

        return (memoryDonors, memoryDonations);
    }
}

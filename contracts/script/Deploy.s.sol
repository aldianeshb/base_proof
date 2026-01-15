// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ProofRegistry} from "../ProofRegistry.sol";
import {ProofVerifier} from "../ProofVerifier.sol";

contract DeployScript is Script {
    function run() external {
        // PRIVATE_KEY should be without 0x prefix in .env
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        string memory network = vm.envString("NETWORK");
        
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("==========================================");
        console.log("BaseProof Contract Deployment");
        console.log("==========================================");
        console.log("Network:", network);
        console.log("Deployer:", msg.sender);
        console.log("");
        
        console.log("Deploying ProofRegistry...");
        ProofRegistry registry = new ProofRegistry();
        console.log("ProofRegistry deployed at:", address(registry));
        
        console.log("Deploying ProofVerifier...");
        ProofVerifier verifier = new ProofVerifier(address(registry));
        console.log("ProofVerifier deployed at:", address(verifier));
        
        vm.stopBroadcast();
        
        console.log("");
        console.log("==========================================");
        console.log("Deployment Summary");
        console.log("==========================================");
        console.log("Network:", network);
        console.log("ProofRegistry:", address(registry));
        console.log("ProofVerifier:", address(verifier));
        console.log("");
        console.log("Next steps:");
        console.log("1. Save these addresses");
        console.log("2. Update backend/.env with PROOF_REGISTRY_ADDRESS");
        console.log("3. Update frontend/.env.local with NEXT_PUBLIC_PROOF_REGISTRY_ADDRESS");
        console.log("4. Update Vercel environment variables");
        console.log("==========================================");
    }
}


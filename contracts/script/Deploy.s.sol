// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ProofRegistry} from "../ProofRegistry.sol";
import {ProofVerifier} from "../ProofVerifier.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        
        console.log("Deploying ProofRegistry...");
        ProofRegistry registry = new ProofRegistry();
        console.log("ProofRegistry deployed at:", address(registry));
        
        console.log("Deploying ProofVerifier...");
        ProofVerifier verifier = new ProofVerifier(address(registry));
        console.log("ProofVerifier deployed at:", address(verifier));
        
        vm.stopBroadcast();
        
        console.log("\n=== Deployment Summary ===");
        console.log("Network:", vm.envString("NETWORK"));
        console.log("ProofRegistry:", address(registry));
        console.log("ProofVerifier:", address(verifier));
    }
}


// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
import '../Eyes.sol';
import '../../libraries/UintStrings.sol';
import '../interfaces/IAnimalSVG.sol';

contract OtterAnimalDescriptors {
    IAnimalSVG public immutable otter;

    constructor(IAnimalSVG _otter){
        otter = _otter;
    }

    function animalSvg(uint8 animalType, uint8 mood) external view returns (string memory){
        string memory moodSVG = moodSvg(mood);
        return otter.svg(moodSVG);
    }

    function moodSvg(uint8 mood) public view returns (string memory){
        if(mood == 1){
            string memory rand1 = UintStrings.decimalString(_randomishIntLessThan('rand1', 4) + 10, 0, false);
            string memory rand2 = UintStrings.decimalString(_randomishIntLessThan('rand2', 5) + 14, 0, false);
            string memory rand3 = UintStrings.decimalString(_randomishIntLessThan('rand3', 3) + 5, 0, false);
            return Eyes.aloof(rand1, rand2, rand3);
        } else {
            return (mood == 2 ? Eyes.sly() : 
                        (mood == 3 ? Eyes.dramatic() : 
                            (mood == 4 ? Eyes.mischievous() : 
                                (mood == 5 ? Eyes.flirty() : Eyes.shy()))));
        }
    }

    function _randomishIntLessThan(bytes32 salt, uint8 n) private view returns (uint8) {
        if (n == 0)
            return 0;
        return uint8(keccak256(abi.encodePacked(block.timestamp, msg.sender, salt))[0]) % n;
    }

    function animalTypeString(uint8 animalType) public view returns (string memory){
        return 'Otter';
    }

    function moodTypeString(uint8 mood) public view returns (string memory){
        return (mood == 1 ? "Aloof" : 
                (mood == 2 ? "Sly" : 
                    (mood == 3 ? "Dramatic" : 
                        (mood == 4 ? "Mischievous" : 
                            (mood == 5 ? "Flirty" : "Shy")))));
    }
}
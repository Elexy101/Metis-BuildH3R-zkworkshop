pragma solidity ^0.8.0;

contract YourContract {
    address public owner;
    uint public payPercentage = 90;
    uint public maxAmountToBet = 0.005 ether;

    struct Game {
        address addr;
        uint blocknumber;
        uint blocktimestamp;
        uint bet;
        uint prize;
        bool winner;
    }

    Game[] public lastPlayedGames;

    event Status(string _msg, address indexed user, uint amount, bool winner);

    constructor(address owner) payable {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    function play() public payable {
        require(msg.value <= maxAmountToBet, "Bet exceeds max amount");

        if (block.timestamp % 2 == 0) {
            uint prize = msg.value * (100 + payPercentage) / 100;
            require(address(this).balance >= prize, "Not enough balance in contract");

            payable(msg.sender).transfer(prize);
            emit Status("Congratulations, you win!", msg.sender, prize, true);

            lastPlayedGames.push(Game({
                addr: msg.sender,
                blocknumber: block.number,
                blocktimestamp: block.timestamp,
                bet: msg.value,
                prize: prize,
                winner: true
            }));

        } else {
            emit Status("Sorry, you lose!", msg.sender, msg.value, false);

            lastPlayedGames.push(Game({
                addr: msg.sender,
                blocknumber: block.number,
                blocktimestamp: block.timestamp,
                bet: msg.value,
                prize: 0,
                winner: false
            }));
        }
    }

    function depositFunds() public payable onlyOwner {
        emit Status("Owner deposited funds", msg.sender, msg.value, true);
    }

    function withdrawFunds(uint amount) public onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance");
        payable(owner).transfer(amount);
        emit Status("Owner withdrew funds", msg.sender, amount, true);
    }

    function setMaxAmountToBet(uint amount) public onlyOwner {
        maxAmountToBet = amount;
    }

    function kill() public onlyOwner {
        emit Status("Contract killed", msg.sender, address(this).balance, true);
        selfdestruct(payable(owner));
    }
}

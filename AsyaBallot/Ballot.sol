// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ballot {
    //голосующий
    struct Voter {
        bool voted; // проголосовал?
        uint vote; // индекс за кого голосовать
    }

    //кандитаты
    struct Proposal {
        string name; // Имя
        uint voteCount; // сколько за него проголосовали
    }

    //owner
    address public owner;

    //адрес => голосующий
    //0xAadnabsdsa => Voter {weight: 1, voted: false, vote: 1}
    mapping(address => Voter) public voters;

    //массив кандидатов
    Proposal[] public proposals;

    //в круглых скобках передаем массив кандитатов(строк)
    constructor(string[] memory proposalNames) {
        //аккаунт с которого запустили контракт является owner
        owner = msg.sender;
        //обращаемся к mapping voters к ключу адреса owner

        //через цикл записываем кандитатов массив proposals из конструктора(proposalNames)
        for (uint i = 0; i < proposalNames.length; i++) {
            //length => длина, proposalNames.length = кол-во элементов в массиве
            proposals.push(
                Proposal({name: proposalNames[i], voteCount: 0}) //метод push он добавляет в массив, в самый конец
            );
        }
    }

    //передаем индекс за кого голосовать (массив кандитатов proposals)
    function vote(uint proposal) public {
        //sender.weight/sender.voter/sender.vote
        //address => голосующий, voters[0x787...] = sender
        Voter storage sender = voters[msg.sender];
        //проверка голосовал ли аккаунт
        require(!sender.voted, "Already voted.");
        //меняем статус на проголосовал
        sender.voted = true;
        //то что передаем в функцию - записываем в struct sender
        sender.vote = proposal;
        //обращаемся к массиву по индексу proposal и увеличиваем его voteCount на 1
        proposals[proposal].voteCount++;
    }

    // function winningProposal() public view returns (uint winningProposal_)
    // {
    //     uint winningVoteCount = 0;
    //     for (uint p = 0; p < proposals.length; p++) {
    //         if (proposals[p].voteCount > winningVoteCount) {
    //             winningVoteCount = proposals[p].voteCount;
    //             winningProposal_ = p;
    //         }
    //     }
    // }
    // function winnerName() public view returns (string memory winnerName_)
    // {
    //     winnerName_ = proposals[winningProposal()].name;
    // }
}

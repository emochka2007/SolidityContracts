//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract StartUp {
    mapping(address => uint) shareholders;
    //время покупки акции
    mapping(address => uint) buyTime;
    //массив акционеров
    address[] public shareholdersArray;

    //покупка акции (передаем процент который хотим купить)
    //чтобы вызвать value == 1 eth
    function buyShare(uint _percentage) external payable {
        //нельзя купить более 50% акций
        //msg.value => сколько перечислено
        require(msg.value < 100e18, "cannot buy more than 50% of project");
        //нельзя владеть более 50% акций
        require(
            shareholders[msg.sender] < 50,
            "cannot own more than 50% of project"
        );
        //неверная сумма в переводе
        //стоимость 1eth
        require(msg.value == _percentage * 1e18, "not correct sum");
        uint percentage = _percentage;
        //добавляем кол-во купленных акций
        shareholders[msg.sender] += percentage;
        //добавляем в массив адрес акционера
        shareholdersArray.push(msg.sender);
        //добавляем в мэппинг время покупки
        //block.timestamp =>время создание блока с транзакцией -> время в секундах прошедшое с 1970 года
        buyTime[msg.sender] = block.timestamp;
    }

    //модификатор - проверяет есть ли у адреса купленные акции
    modifier ifShareholder(address _addr) {
        require(shareholders[_addr] > 0, "not a shareholder");
        _;
    }
    //проверяет прошло ли время для подсчета и выплаты дивидендов
    modifier ifYearPassed() {
        //block.timestamp  - время транзакции
        require(
            (block.timestamp - buyTime[msg.sender]) > 20 seconds,
            "Year has not passed yet"
        );
        _;
    }

    //считаем дивиденды
    function countDividends(
        address _addr
    ) public view ifShareholder(_addr) ifYearPassed returns (uint) {
        //долю адреса конвертируем в eth и считаем 1%
        uint dividend = (shareholders[_addr] * 1e18) / 100;
        //возвращаем сумму
        return dividend;
    }

    //отравляем дивиденды
    function sendDividends(
        address payable _addr
    ) public payable ifShareholder(_addr) ifYearPassed {
        //подсчет дивидендов у адреса
        uint eth = countDividends(_addr);
        //перевод на адрес с баланса смарт-контракта
        _addr.transfer(eth);
        //перезаписываем время покупки, для отсчета заново
        buyTime[msg.sender] = block.timestamp;
    }

    //узнать процент доли у адреса
    function showPercentage(address _addr) public view returns (uint) {
        return shareholders[_addr];
    }

    //возврат средств
    function returnFunds(
        address payable _addr
    ) public ifShareholder(_addr) ifYearPassed returns (string memory) {
        //если кол-во акционеров меньше единицы через определенное время, то стартап провалился и вернут деньги
        if (shareholdersArray.length < 5) {
            //возвращаем на адрес средства
            _addr.transfer(shareholders[_addr] * 1e18);
            //обнуляем процент акций после refund
            shareholders[_addr] = 0;
            return "Money returned";
            //в противном случае просто возвращаем строку, что стартап был успешный
        } else {
            return "Startup is succesful";
        }
    }
}

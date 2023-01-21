// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BuyLicenses {
    //map покупателей
    mapping(address => bool) buyers;
    //map первоначального баланса
    mapping(address => uint) initialBalance;
    //map время покупки прав
    mapping(address => uint) buyersTimestamp;
    //учет выплат роялти
    mapping(address => uint) royalties;
    //время покупки
    uint buyTime;
    //увеличение баланса
    uint increaseOfBalance;

    //функция для осуществления перевода между аккаунтами
    function transferToAccount(address payable _address, uint amount) public {
        //трансфер метод для перевода
        _address.transfer(amount);
    }

    //для получения денег на смарт контракт
    function receiveEth() external payable {}

    //проверка купил ли
    function _isBuyer(address _address) public view returns (bool) {
        //проверка на существование адреса внутри мэппинга
        if (buyers[_address]) {
            return true;
        }
        // not a buyer
        return false;
    }

    //узнать баланс аккаунта
    function getBalance(address _address) internal {
        //добавляем в мэппинг значение
        initialBalance[_address] = _address.balance;
    }

    //функция покупки
    function buy() public payable {
        //создаем переменную у адреса который вызывает функцию
        address currBuyer = msg.sender;
        //проверка покупал ли адрес права до этого, если да, то отменяем функцию
        require(!_isBuyer(currBuyer), "already bought");
        // not == 1eth
        //проверка на сумму транзакции, если больше или меньше 1 эфира, то отмена
        require(msg.value == 1e18, "not correct sum");
        //добавляем в мэппинг адрес со значение тру
        buyers[currBuyer] = true;
        //добавляем баланс юзера в мэппинг балансов
        getBalance(currBuyer);
        //время покупки = время созданию блока с транзакцией
        buyTime = block.timestamp;
        //добавляем в мэппинг с временем покупок, адрес с которого купили
        buyersTimestamp[msg.sender] = buyTime;
    }

    //проверка - прошло ли время
    function _isTimePassed() internal view returns (bool) {
        return (block.timestamp >= (buyTime + 10 seconds));
    }

    //считаем роялти, 1% с прибыли
    function _calculateRoyalties(address _address) public view returns (uint) {
        // to prevent function from calling by someone who doesn't own song licence.
        require(_isBuyer(_address), "does not buy licence");
        //сравнение нынешнего баланса и баланса на момент покупки
        //если баланс нынешний больше, то считаем роялти
        if (initialBalance[_address] < _address.balance) {
            return (_address.balance - initialBalance[_address]) / 100;
        }
        //если баланс меньше, то возвращаем ноль
        else {
            return 0;
        }
    }

    //забираем права, если адрес не платил роялти
    function takeLicenceAwayIfNotRoyaltiesPaied(address _address) public {
        //проверка на время
        require(_isTimePassed(), "time Has Not Passed");
        // to prevent function from calling by someone who doesn't own song licence.
        require(_isBuyer(_address), "does not buy licence");
        //считаем роялти
        uint _royaltie = _calculateRoyalties(_address);
        //если значение больше нуля, то баланс увеличился на адресе, значит надо было заплатить роялти
        if (_royaltie > 0) {
            //если роялти меньше, чем было посчитано, то забираем права у адреса
            if (royalties[_address] < _royaltie) {
                buyers[_address] = false;
                //если столько же или больше, то мы добавляем баланс аккаунта в мэппинг балансов, чтобы теперь считало с новым балансом
            } else {
                initialBalance[_address] = _address.balance;
            }
        }
    }

    //функция для отправки роялти
    function payRoyalties() public payable {
        // to prevent function from calling by someone who doesn't own song licence.
        require(_isBuyer(msg.sender), "does not buy licence");
        //добавляем адрес в мэппинг со значением "сумма транзакции"
        royalties[msg.sender] += msg.value;
    }

    //посмотреть какое роялти у определенного аккаунта
    function showRoyalties(address _address) public view returns (uint) {
        return royalties[_address];
    }
}

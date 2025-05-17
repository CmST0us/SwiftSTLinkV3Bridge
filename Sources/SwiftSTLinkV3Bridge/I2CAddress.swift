public enum I2CAddress {
    case address7Bit(UInt8)
    case address8BitWrite(UInt8)
    case address8BitRead(UInt8)
    case address10Bit(UInt16)

    /// 获取7位地址
    public var address7Bit: UInt8? {
        switch self {
        case .address7Bit(let addr):
            return addr
        case .address8BitWrite(let addr):
            return addr >> 1
        case .address8BitRead(let addr):
            return addr >> 1
        case .address10Bit(let addr):
            if addr <= 0x3FF {
                return UInt8(addr & 0x7F)
            } else {
                return nil
            }
        }
    }

    /// 获取8位写地址
    public var address8BitWrite: UInt8? {
        switch self {
        case .address7Bit(let addr):
            return addr << 1
        case .address8BitWrite(let addr):
            return addr
        case .address8BitRead(let addr):
            return addr & 0xFE
        case .address10Bit(let addr):
            if addr <= 0x3FF {
                let msb = 0xF0 | UInt8((addr >> 7) & 0x06)
                // 10位地址写时，先发msb+写位0，再发lsb
                return msb // 仅返回高字节部分
            } else {
                return nil
            }
        }
    }

    /// 获取8位读地址
    public var address8BitRead: UInt8? {
        switch self {
        case .address7Bit(let addr):
            return (addr << 1) | 0x01
        case .address8BitWrite(let addr):
            return addr | 0x01
        case .address8BitRead(let addr):
            return addr
        case .address10Bit(let addr):
            if addr <= 0x3FF {
                let msb = 0xF0 | UInt8((addr >> 7) & 0x06) | 0x01
                return msb // 仅返回高字节部分
            } else {
                return nil
            }
        }
    }

    /// 获取10位地址
    public var address10Bit: UInt16? {
        switch self {
        case .address7Bit(let addr):
            return UInt16(addr)
        case .address8BitWrite(let addr):
            return UInt16(addr >> 1)
        case .address8BitRead(let addr):
            return UInt16(addr >> 1)
        case .address10Bit(let addr):
            return addr
        }
    }
}
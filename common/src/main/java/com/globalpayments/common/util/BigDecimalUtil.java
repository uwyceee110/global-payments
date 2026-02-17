package com.globalpayments.common.util;

import java.math.BigDecimal;
import java.math.RoundingMode;

public class BigDecimalUtil {
    public static BigDecimal usdToUsdc(BigDecimal usd) {
        return usd.setScale(6, RoundingMode.DOWN);
    }
}

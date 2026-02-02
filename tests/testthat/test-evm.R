test_that("Planned Value (PV) calculation is correct", {
  bac <- 100000
  schedule <- c(0.1, 0.2, 0.4, 0.7, 1.0)
  time_period <- 3

  pv_value <- pv(bac, schedule, time_period)
  expect_equal(pv_value, 40000)
})

test_that("Earned Value (EV) calculation is correct", {
  bac <- 100000
  actual_per_complete <- 0.35

  ev_value <- ev(bac, actual_per_complete)
  expect_equal(ev_value, 35000)
})

test_that("Actual Cost (AC) calculation is correct", {
  actual_costs <- c(9000, 18000, 36000, 70000, 100000)
  time_period <- 3

  ac_value <- ac(actual_costs, time_period)
  expect_equal(ac_value, 36000)
})

test_that("Schedule Variance (SV) calculation is correct", {
  ev_value <- 35000
  pv_value <- 40000

  sv_value <- sv(ev_value, pv_value)
  expect_equal(sv_value, -5000)
})

test_that("Cost Variance (CV) calculation is correct", {
  ev_value <- 35000
  ac_value <- 36000

  cv_value <- cv(ev_value, ac_value)
  expect_equal(cv_value, -1000)
})

test_that("Schedule Performance Index (SPI) calculation is correct", {
  ev_value <- 35000
  pv_value <- 40000

  spi_value <- spi(ev_value, pv_value)
  expect_equal(spi_value, 0.875)
})

test_that("Cost Performance Index (CPI) calculation is correct", {
  ev_value <- 35000
  ac_value <- 36000

  cpi_value <- cpi(ev_value, ac_value)
  expect_equal(cpi_value, 0.9722222, tolerance = 1e-6)
})

# ============================================================================
# PV Error Handling Tests
# ============================================================================
test_that("pv validates NULL inputs", {
  expect_error(pv(NULL, c(0.1, 0.2), 1), "bac, schedule, and time_period must not be NULL")
  expect_error(pv(100000, NULL, 1), "bac, schedule, and time_period must not be NULL")
  expect_error(pv(100000, c(0.1, 0.2), NULL), "bac, schedule, and time_period must not be NULL")
})

test_that("pv validates numeric inputs", {
  expect_error(pv("100000", c(0.1, 0.2), 1), "bac, schedule, and time_period must be numeric")
  expect_error(pv(100000, "schedule", 1), "bac, schedule, and time_period must be numeric")
  expect_error(pv(100000, c(0.1, 0.2), "1"), "bac, schedule, and time_period must be numeric")
})

test_that("pv validates single value inputs", {
  expect_error(pv(c(100000, 200000), c(0.1, 0.2), 1), "bac must be a single numeric value")
  expect_error(pv(100000, c(0.1, 0.2), c(1, 2)), "time_period must be a single numeric value")
})

test_that("pv validates NA inputs", {
  # NA alone is logical, so it fails numeric check first; use NA_real_ for numeric NA
  expect_error(pv(NA_real_, c(0.1, 0.2), 1), "bac, schedule, and time_period must not contain NA values")
  expect_error(pv(100000, c(0.1, NA), 1), "bac, schedule, and time_period must not contain NA values")
  expect_error(pv(100000, c(0.1, 0.2), NA_real_), "bac, schedule, and time_period must not contain NA values")
})

test_that("pv validates schedule range", {
  expect_error(pv(100000, c(0.1, 1.5), 1), "schedule values must be between 0 and 1")
  expect_error(pv(100000, c(-0.1, 0.5), 1), "schedule values must be between 0 and 1")
})

test_that("pv validates time_period range", {
  expect_error(pv(100000, c(0.1, 0.2, 0.5), 0), "time_period must be within the range of the schedule vector")
  expect_error(pv(100000, c(0.1, 0.2, 0.5), 5), "time_period must be within the range of the schedule vector")
})

test_that("pv validates non-negative bac", {
  expect_error(pv(-100000, c(0.1, 0.2), 1), "bac must be non-negative")
})

test_that("pv validates non-empty schedule", {
  expect_error(pv(100000, numeric(0), 1), "schedule must not be empty")
})

# ============================================================================
# EV Error Handling Tests
# ============================================================================
test_that("ev validates NULL inputs", {
  expect_error(ev(NULL, 0.5), "bac and actual_per_complete must not be NULL")
  expect_error(ev(100000, NULL), "bac and actual_per_complete must not be NULL")
})

test_that("ev validates numeric inputs", {
  expect_error(ev("100000", 0.5), "bac and actual_per_complete must be numeric")
  expect_error(ev(100000, "0.5"), "bac and actual_per_complete must be numeric")
})

test_that("ev validates single value inputs", {
  expect_error(ev(c(100000, 200000), 0.5), "bac must be a single numeric value")
  expect_error(ev(100000, c(0.3, 0.5)), "actual_per_complete must be a single numeric value")
})

test_that("ev validates percentage range", {
  expect_error(ev(100000, 1.5), "actual_per_complete must be between 0 and 1")
  expect_error(ev(100000, -0.1), "actual_per_complete must be between 0 and 1")
})

test_that("ev validates non-negative bac", {
  expect_error(ev(-100000, 0.5), "bac must be non-negative")
})

# ============================================================================
# AC Tests
# ============================================================================
test_that("ac works with cumulative costs (default)", {
  cumulative_costs <- c(9000, 27000, 63000)
  expect_equal(ac(cumulative_costs, 2), 27000)
  expect_equal(ac(cumulative_costs, 3), 63000)
})

test_that("ac works with period costs", {
  period_costs <- c(9000, 18000, 36000)
  expect_equal(ac(period_costs, 2, cumulative = FALSE), 27000)
  expect_equal(ac(period_costs, 3, cumulative = FALSE), 63000)
})

test_that("ac validates NULL inputs", {
  expect_error(ac(NULL, 1), "actual_costs and time_period must not be NULL")
  expect_error(ac(c(1000, 2000), NULL), "actual_costs and time_period must not be NULL")
})

test_that("ac validates cumulative parameter", {
  expect_error(ac(c(1000, 2000), 1, cumulative = "yes"), "cumulative must be a single logical value")
  expect_error(ac(c(1000, 2000), 1, cumulative = c(TRUE, FALSE)), "cumulative must be a single logical value")
})

test_that("ac validates non-negative costs", {
  expect_error(ac(c(1000, -2000), 1), "actual_costs must be non-negative")
})

# ============================================================================
# SV Error Handling Tests
# ============================================================================
test_that("sv validates NULL inputs", {
  expect_error(sv(NULL, 40000), "ev and pv must not be NULL")
  expect_error(sv(35000, NULL), "ev and pv must not be NULL")
})

test_that("sv validates non-negative inputs", {
  expect_error(sv(-35000, 40000), "ev must be non-negative")
  expect_error(sv(35000, -40000), "pv must be non-negative")
})

# ============================================================================
# CV Error Handling Tests
# ============================================================================
test_that("cv validates NULL inputs", {
  expect_error(cv(NULL, 36000), "ev and ac must not be NULL")
  expect_error(cv(35000, NULL), "ev and ac must not be NULL")
})

test_that("cv validates non-negative inputs", {
  expect_error(cv(-35000, 36000), "ev must be non-negative")
  expect_error(cv(35000, -36000), "ac must be non-negative")
})

# ============================================================================
# SPI Error Handling Tests
# ============================================================================
test_that("spi validates NULL inputs", {
  expect_error(spi(NULL, 40000), "ev and pv must not be NULL")
  expect_error(spi(35000, NULL), "ev and pv must not be NULL")
})

test_that("spi validates pv greater than zero", {
  expect_error(spi(35000, 0), "pv must be greater than zero")
  expect_error(spi(35000, -40000), "pv must be greater than zero")
})

# ============================================================================
# CPI Error Handling Tests
# ============================================================================
test_that("cpi validates NULL inputs", {
  expect_error(cpi(NULL, 36000), "ev and ac must not be NULL")
  expect_error(cpi(35000, NULL), "ev and ac must not be NULL")
})

test_that("cpi validates ac greater than zero", {
  expect_error(cpi(35000, 0), "ac must be greater than zero")
  expect_error(cpi(35000, -36000), "ac must be greater than zero")
})

# ============================================================================
# EAC Tests
# ============================================================================
test_that("eac typical method calculation is correct", {
  bac <- 100000
  cpi_val <- 0.8
  expected <- bac / cpi_val
  expect_equal(eac(bac, cpi = cpi_val), expected)
})

test_that("eac atypical method calculation is correct", {
  bac <- 100000
  ac_val <- 63000
  ev_val <- 35000
  expected <- ac_val + (bac - ev_val)
  expect_equal(eac(bac, method = "atypical", ac = ac_val, ev = ev_val), expected)
})

test_that("eac combined method calculation is correct", {
  bac <- 100000
  cpi_val <- 0.8
  spi_val <- 0.9
  ac_val <- 63000
  ev_val <- 35000
  expected <- ac_val + (bac - ev_val) / (cpi_val * spi_val)
  expect_equal(eac(bac, method = "combined", cpi = cpi_val, ac = ac_val, ev = ev_val, spi = spi_val), expected)
})

test_that("eac validates method parameter", {
  expect_error(eac(100000, method = "invalid"), "method must be one of: typical, atypical, combined")
})

test_that("eac typical method validates required parameters", {
  expect_error(eac(100000, method = "typical"), "cpi is required for the 'typical' method")
  expect_error(eac(100000, method = "typical", cpi = 0), "cpi must be greater than zero")
})

test_that("eac atypical method validates required parameters", {
  expect_error(eac(100000, method = "atypical", ac = 63000), "ac and ev are required for the 'atypical' method")
  expect_error(eac(100000, method = "atypical", ev = 35000), "ac and ev are required for the 'atypical' method")
})

test_that("eac combined method validates required parameters", {
  expect_error(eac(100000, method = "combined", cpi = 0.8, ac = 63000, ev = 35000),
               "cpi, ac, ev, and spi are required for the 'combined' method")
  expect_error(eac(100000, method = "combined", cpi = 0, ac = 63000, ev = 35000, spi = 0.9),
               "cpi and spi must be greater than zero")
})

test_that("eac validates bac", {
  expect_error(eac(NULL, cpi = 0.8), "bac must not be NULL")
  expect_error(eac(-100000, cpi = 0.8), "bac must be non-negative")
})

# ============================================================================
# ETC Tests
# ============================================================================
test_that("etc calculation without cpi is correct", {
  bac <- 100000
  ev_val <- 35000
  expected <- bac - ev_val
  expect_equal(etc(bac, ev_val), expected)
})

test_that("etc calculation with cpi is correct", {
  bac <- 100000
  ev_val <- 35000
  cpi_val <- 0.8
  expected <- (bac - ev_val) / cpi_val
  expect_equal(etc(bac, ev_val, cpi_val), expected)
})

test_that("etc validates NULL inputs", {
  expect_error(etc(NULL, 35000), "bac and ev must not be NULL")
  expect_error(etc(100000, NULL), "bac and ev must not be NULL")
})

test_that("etc validates cpi greater than zero", {
  expect_error(etc(100000, 35000, 0), "cpi must be greater than zero")
  expect_error(etc(100000, 35000, -0.5), "cpi must be greater than zero")
})

test_that("etc validates non-negative inputs", {
  expect_error(etc(-100000, 35000), "bac and ev must be non-negative")
  expect_error(etc(100000, -35000), "bac and ev must be non-negative")
})

# ============================================================================
# VAC Tests
# ============================================================================
test_that("vac calculation is correct", {
  bac <- 100000
  eac_val <- 120000
  expected <- bac - eac_val
  expect_equal(vac(bac, eac_val), expected)
})

test_that("vac validates NULL inputs", {
  expect_error(vac(NULL, 120000), "bac and eac must not be NULL")
  expect_error(vac(100000, NULL), "bac and eac must not be NULL")
})

test_that("vac validates non-negative inputs", {
  expect_error(vac(-100000, 120000), "bac and eac must be non-negative")
  expect_error(vac(100000, -120000), "bac and eac must be non-negative")
})

# ============================================================================
# TCPI Tests
# ============================================================================
test_that("tcpi to BAC calculation is correct", {
  bac <- 100000
  ev_val <- 35000
  ac_val <- 40000
  expected <- (bac - ev_val) / (bac - ac_val)
  expect_equal(tcpi(bac, ev_val, ac_val), expected)
})

test_that("tcpi to EAC calculation is correct", {
  bac <- 100000
  ev_val <- 35000
  ac_val <- 40000
  eac_val <- 120000
  expected <- (bac - ev_val) / (eac_val - ac_val)
  expect_equal(tcpi(bac, ev_val, ac_val, target = "eac", eac = eac_val), expected)
})

test_that("tcpi validates NULL inputs", {
  expect_error(tcpi(NULL, 35000, 40000), "bac, ev, and ac must not be NULL")
  expect_error(tcpi(100000, NULL, 40000), "bac, ev, and ac must not be NULL")
  expect_error(tcpi(100000, 35000, NULL), "bac, ev, and ac must not be NULL")
})

test_that("tcpi validates target parameter", {
  expect_error(tcpi(100000, 35000, 40000, target = "invalid"), "target must be either 'bac' or 'eac'")
})

test_that("tcpi validates eac required for eac target", {
  expect_error(tcpi(100000, 35000, 40000, target = "eac"), "eac is required when target = 'eac'")
})

test_that("tcpi validates denominator not zero for BAC target", {
  expect_error(tcpi(100000, 35000, 100000), "Cannot calculate TCPI: actual cost already meets or exceeds budget")
})

test_that("tcpi validates denominator not zero for EAC target", {
  expect_error(tcpi(100000, 35000, 120000, target = "eac", eac = 120000),
               "Cannot calculate TCPI: actual cost already meets or exceeds EAC")
})

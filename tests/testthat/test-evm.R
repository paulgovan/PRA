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

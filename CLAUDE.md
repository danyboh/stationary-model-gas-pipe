# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MATLAB codebase for modeling natural gas pressure and temperature distribution in pipeline transportation. Uses VNIC SMV (GOST 30319.2-96) and GERG-91 equations of state to solve coupled ODEs for a 122 km Ukrainian regional pipeline (Dᵢ=1.388m). Validates against ~1000 experimental data points sampled at 2-hour intervals over ~10 months.

## Running

All files are MATLAB scripts/functions executed directly in MATLAB (R2017+). No build system.

```matlab
% Main simulation (pressure + temperature profiles along pipeline)
Danyltsiv_perev
```

**Required toolboxes:** standard ODE solver (ode45).

## Architecture

### ODE Model (core flow equations)
- **SystRivn_v_2_Danyl.m** — Full coupled system: solves dp/dx and dT/dx simultaneously using ode45. Includes friction, kinetic energy, Joule-Thomson cooling, and convective heat transfer terms.

### Thermophysical Property Functions
These are called by the ODE model to compute gas properties at each solver step:
- **Fvnic.m** → compressibility factor Z and molar density (VNIC SMV equation of state)
- **fdens.m** → iterative molar density solver (called by Fvnic)
- **dat_vnic.m** → critical parameters, binary interaction coefficients, polynomial coefficients for VNIC SMV
- **Cp_Vnic.m** → heat capacity Cp, density, molar mass
- **calkcpo.m** → ideal gas heat capacity polynomials for 8-component mixture
- **FGerg91.m** → GERG-91 compressibility (used for Joule-Thomson and viscosity)
- **met_nulp.m** → Joule-Thomson coefficient
- **VisG1.m** → dynamic viscosity (GOST 30319.1-96)

### Utility Functions
- **day2sec.m** → converts days to seconds
- **k2c.m** → converts Kelvin to Celsius

### Call Chain
`Danyltsiv_perev` → ode45 → `SystRivn_v_2_Danyl` → {`Fvnic`→`fdens`+`dat_vnic`, `Cp_Vnic`→`calkcpo`, `FGerg91`, `met_nulp`, `VisG1`}

### Experimental Data (`*_data.m` files)
Each file defines a column vector of ~1000 measurements: `P0_data` (inlet pressure), `pk_data` (outlet pressure), `Q_data` (flow rate), `RO0_data` (density), `T1_data`/`t2_data` (temperatures), `tg_data` (ground temp).

## Key Constants

- Gas composition: 8-component (CH₄ 93.6%, C₂H₆ 3.1%, C₃H₈ 0.9%, trace butanes, N₂ 1.2%, CO₂ 0.9%)
- Pipeline: L=122km, Dᵢ=1.388m, roughness=0.2mm, flat terrain
- ODE tolerances: RelTol=1e-6, AbsTol=1e-9, MaxStep=100m
- Code comments are a mix of English and Ukrainian

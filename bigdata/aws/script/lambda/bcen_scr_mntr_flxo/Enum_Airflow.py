from enum import Enum


class DAG(Enum):
    bcen_scr_pcpl = "bcen_scr_pcpl"
    bcen_scr_base_ctle = "bcen_scr_base_ctle"
    bcen_scr_rmss_ctle = "bcen_scr_rmss_ctle"


class EVENT(Enum):
    check = "check"
    start = "start"
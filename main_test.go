package main

import (
    "testing"

    "github.com/coredns/coredns/core/dnsserver"
)

func TestInit(t *testing.T) {
    var found bool
    for _, included := range dnsserver.Directives {
        if included == "multicluster" {
            found = true
        }
    }
    if !found {
        t.Errorf("'k8s_gateway' plugin is not found in the list")
    }
}

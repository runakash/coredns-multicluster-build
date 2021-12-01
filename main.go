package main

import (
	_ "github.com/coredns/coredns/core/plugin"
	_ "github.com/coredns/multicluster"

	"github.com/coredns/coredns/core/dnsserver"
	"github.com/coredns/coredns/coremain"
)

func init() {
	// insert multicluster plugin after kubernetes plugin
	for i, name := range dnsserver.Directives {
		if name == "kubernetes" {
			dnsserver.Directives = append(dnsserver.Directives[:i],
				append([]string{"multicluster"}, dnsserver.Directives[i:]...)...)
			return
		}
	}
	panic("kubernetes plugin not found in dnsserver.Directives")
}

func main() {
	coremain.Run()
}

# Copyright (c) 1997 Regents of the University of California.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. All advertising materials mentioning features or use of this software
#    must display the following acknowledgement:
#      This product includes software developed by the Computer Systems
#      Engineering Group at Lawrence Berkeley Laboratory.
# 4. Neither the name of the University nor of the Laboratory may be used
#    to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# A simple example for wireless simulation using nrlolsr/protolib source code

# ======================================================================
# Define options
# ======================================================================
set val(chan)           Channel/WirelessChannel    ;# channel type
set val(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set val(netif)          Phy/WirelessPhy            ;# network interface type
set val(mac)            Mac/802_11                 ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue    ;# interface queue type
set val(ll)             LL                         ;# link layer type
set val(ant)            Antenna/OmniAntenna        ;# antenna model
set val(ifqlen)         50                         ;# max packet in ifq
set val(nn)             20                         ;# number of mobilenodes
set val(rp)             ProtolibMK         ;# routing protocol
set val(x)	500;
set val(y)	500;
# set opt(energymodel) EnergyModel;
# set opt(radiomodel) RadioModel;
# set opt(initialenergy) 1000;

Phy/WirelessPhy set CSThresh_ 4.21756e-11;
Phy/WirelessPhy set RXThresh_ 4.4613e-10;

set state flag
foreach arg $argv {
	switch -- $state {
		flag {
		switch -- $arg {
			manet	{set state manet}
			help	{Usage}
			default	{error "unknown flag $arg"}
		}
		}
		
		manet	{set state flag; set val(rp) $arg}
		
	}
	
}

puts "this is a mobile network test program using nrlolsr/protolib"
# =====================================================================
# Main Program
# ======================================================================

#
# Initialize Global Variables
#
set ns_		[new Simulator]
set tracefd     [open olsrdemo.tr w]
$ns_ trace-all $tracefd


# 
set namtrace [open olsrdemo.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

$ns_ color 0 red
$ns_ color 1 blue

# set up topography object
set topo       [new Topography]

$topo load_flatgrid $val(x) $val(y)

#
# Create God
#
create-god $val(nn)

# configure node
set chan_1_ [new $val(chan)]

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(prop) \
			 -phyType $val(netif) \
			 -channel $chan_1_ \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace OFF \
			 -movementTrace ON
			 # -energyModel $opt(energymodel) \
			 # -idlePower 1.0 \
			 # -rxPower 1.0 \
			 # -txPower 2.0 \
			 # -sleepPower 0.001 \
			 # -transitionPower 0.2 \
			 # -transitionTime 0.005 \
			 # -initialEnergy $opt(initialenergy)		

	for {set i 0} {$i < $val(nn) } {incr i} {
	        set node_($i) [$ns_ node]	
		$node_($i) random-motion 1
				;# enable random motion
	}
	for {set i 0} {$i < $val(nn) } {incr i} {
		$ns_ initial_node_pos $node_($i) 25		;# disable random motion
	}
if {$val(rp) == "ProtolibMK"} {
    for {set i 0} {$i < $val(nn) } {incr i} {
	    set p($i) [new Agent/NrlolsrAgent]
	    $ns_ attach-agent $node_($i) $p($i)
	    $ns_ at 0.0 "$p($i) startup -tcj .75 -hj .5 -tci 2.5 -hi .5 -d 8 -l /tmp/olsr.log"
	    [$node_($i) set ragent_] attach-manet $p($i)
	    $p($i) attach-protolibmk [$node_($i) set ragent_]
    }
}

set totaltime 90.0
set runtime $totaltime

#Make 5 nodes as a clsuter

# cluster1
set nextx 100.0
set nexty 100.0
 $node_(0) set X_ $nextx
 $node_(0) set Y_ $nexty
 $ns_ at 0.0 "$node_(0) setdest $nextx $nexty 0.0"
set nextx 160.0
set nexty 100.0
 $node_(1) set X_ $nextx
 $node_(1) set Y_ $nexty
 $ns_ at 0.0 "$node_(1) setdest $nextx $nexty 0.0"
set nextx 100.0
set nexty 160.0
 $node_(2) set X_ $nextx
 $node_(2) set Y_ $nexty
 $ns_ at 0.0 "$node_(2) setdest $nextx $nexty 0.0"
set nextx 160.0
set nexty 160.0
 $node_(3) set X_ $nextx
 $node_(3) set Y_ $nexty
 $ns_ at 0.0 "$node_(3) setdest $nextx $nexty 0.0"
set nextx 130.0
set nexty 130.0
 $node_(4) set X_ $nextx
 $node_(4) set Y_ $nexty
 $ns_ at 0.0 "$node_(4) setdest $nextx $nexty 0.0"

# cluster2
set nextx 300.0
set nexty 100.0
 $node_(5) set X_ $nextx
 $node_(5) set Y_ $nexty
 $ns_ at 0.0 "$node_(5) setdest $nextx $nexty 0.0"
set nextx 360.0
set nexty 100.0
 $node_(6) set X_ $nextx
 $node_(6) set Y_ $nexty
 $ns_ at 0.0 "$node_(6) setdest $nextx $nexty 0.0"
set nextx 300.0
set nexty 160.0
 $node_(7) set X_ $nextx
 $node_(7) set Y_ $nexty
 $ns_ at 0.0 "$node_(7) setdest $nextx $nexty 0.0"
set nextx 360.0
set nexty 160.0
 $node_(8) set X_ $nextx
 $node_(8) set Y_ $nexty
 $ns_ at 0.0 "$node_(8) setdest $nextx $nexty 0.0"
set nextx 330.0
set nexty 130.0
 $node_(9) set X_ $nextx
 $node_(9) set Y_ $nexty
 $ns_ at 0.0 "$node_(9) setdest $nextx $nexty 0.0"

# cluster3
set nextx 100.0
set nexty 300.0
 $node_(10) set X_ $nextx
 $node_(10) set Y_ $nexty
 $ns_ at 0.0 "$node_(10) setdest $nextx $nexty 0.0"
set nextx 160.0
set nexty 300.0
 $node_(11) set X_ $nextx
 $node_(11) set Y_ $nexty
 $ns_ at 0.0 "$node_(11) setdest $nextx $nexty 0.0"
set nextx 100.0
set nexty 360.0
 $node_(12) set X_ $nextx
 $node_(12) set Y_ $nexty
 $ns_ at 0.0 "$node_(12) setdest $nextx $nexty 0.0"
set nextx 160.0
set nexty 360.0
 $node_(13) set X_ $nextx
 $node_(13) set Y_ $nexty
 $ns_ at 0.0 "$node_(13) setdest $nextx $nexty 0.0"
set nextx 130.0
set nexty 330.0
 $node_(14) set X_ $nextx
 $node_(14) set Y_ $nexty
 $ns_ at 0.0 "$node_(14) setdest $nextx $nexty 0.0"

# cluster4
set nextx 300.0
set nexty 300.0
 $node_(15) set X_ $nextx
 $node_(15) set Y_ $nexty
 $ns_ at 0.0 "$node_(15) setdest $nextx $nexty 0.0"
set nextx 360.0
set nexty 300.0
 $node_(16) set X_ $nextx
 $node_(16) set Y_ $nexty
 $ns_ at 0.0 "$node_(16) setdest $nextx $nexty 0.0"
set nextx 300.0
set nexty 360.0
 $node_(17) set X_ $nextx
 $node_(17) set Y_ $nexty
 $ns_ at 0.0 "$node_(17) setdest $nextx $nexty 0.0"
set nextx 360.0
set nexty 360.0
 $node_(18) set X_ $nextx
 $node_(18) set Y_ $nexty
 $ns_ at 0.0 "$node_(18) setdest $nextx $nexty 0.0"
set nextx 330.0
set nexty 330.0
 $node_(19) set X_ $nextx
 $node_(19) set Y_ $nexty
 $ns_ at 0.0 "$node_(19) setdest $nextx $nexty 0.0"

# SEtup CBR agents

proc ranstart { first last } {
	global agentstart
	set interval [expr $last - $first]
	set maxrval [expr pow(2,31)]
	set intrval [expr $interval/$maxrval]
	set agentstart [expr ([ns-random] * $intrval) + $first]
}

ns-random 0 # seed the thing heuristically
set agentstart 5.0

set udp(0) [new Agent/UDP]
$ns_ attach-agent $node_(4) $udp(0)
set cbr(0) [new Application/Traffic/CBR]
$cbr(0) attach-agent $udp(0)
$cbr(0) set packetSize_ 1000
$cbr(0) set rate_ 30mb
$cbr(0) set interval_ 0.05
$cbr(0) set random_ false
ranstart 2.0 5.0
$ns_ at $agentstart "$cbr(0) start"

set udp(1) [new Agent/UDP]
$ns_ attach-agent $node_(9) $udp(1)
set cbr(1) [new Application/Traffic/CBR]
$cbr(1) attach-agent $udp(1)
$cbr(1) set packetSize_ 1000
$cbr(0) set rate_ 30mb
$cbr(1) set interval_ 0.05
$cbr(1) set random_ false
ranstart 2.0 5.0
$ns_ at $agentstart "$cbr(1) start"

set udp(2) [new Agent/UDP]
$ns_ attach-agent $node_(14) $udp(2)
set cbr(2) [new Application/Traffic/CBR]
$cbr(2) attach-agent $udp(2)
$cbr(2) set packetSize_ 1000
$cbr(0) set rate_ 30mb
$cbr(2) set interval_ 0.05
$cbr(2) set random_ false
ranstart 2.0 5.0
$ns_ at $agentstart "$cbr(2) start"

set udp(3) [new Agent/UDP]
$ns_ attach-agent $node_(19) $udp(3)
set cbr(3) [new Application/Traffic/CBR]
$cbr(3) attach-agent $udp(3)
$cbr(3) set packetSize_ 1000
$cbr(0) set rate_ 30mb
$cbr(3) set interval_ 0.05
$cbr(3) set random_ false
ranstart 2.0 5.0
$ns_ at $agentstart "$cbr(3) start"


set null1 [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $null1
$ns_ connect $udp(1) $null1

set null2 [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $null2
$ns_ connect $udp(2) $null2

set null3 [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $null3
$ns_ connect $udp(3) $null3



#Tell nodes when the simulation ends

for {set i 1 } {$i < $val(nn) } {incr i} {
    $ns_ at $runtime "$node_($i) reset";
}
$ns_ at $runtime "stop"
$ns_ at $runtime "puts \"NS EXITING...\" ; $ns_ halt"

proc stop {} {
    global ns_ null1 null2 null3 namtrace tracefd runtime
    set bw0 [$null1 set bytes_]
    set bw1 [$null2 set bytes_]
    set bw2 [$null3 set bytes_]
    puts "Cbr agent0<-9 received [expr $bw0/$runtime*8/1000] Kbps"
    puts "Cbr agent0<-14 received [expr $bw1/$runtime*8/1000] Kbps"
    puts "Cbr agent0<-19 received [expr $bw2/$runtime*8/1000] Kbps"
    $ns_ flush-trace
 
    close $tracefd
   close $namtrace
    exit 0
}

#Begin command line parsing

proc Usage {} {
    puts {PARAMETERS NEED NOT BE SPECIFIED... DEFAULTS WILL BE USED}
    exit
}        

	
puts "Starting Simulation..."

$ns_ run




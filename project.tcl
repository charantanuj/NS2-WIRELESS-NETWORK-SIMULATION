# Define options
set val(chan) Channel/WirelessChannel ;# channel type
set val(prop) Propagation/TwoRayGround ;# radio-propagation model
set val(netif) Phy/WirelessPhy ;# network interface type
set val(mac) Mac/802_11 ;# MAC type
set val(ifq) Queue/DropTail/PriQueue ;# interface queue type
set val(ll) LL ;# link layer type
set val(ant) Antenna/OmniAntenna ;# antenna model
set val(ifqlen) 50 ;# max packet in ifq
set val(nn) 6 ;# number of mobilenodes
set val(rp) AODV ;# routing protocol
set val(x) 400 ;# X dimension of topography
set val(y) 400 ;# Y dimension of topography
set val(stop) 150 ;# time of simulation end

set ns [new Simulator]
set tracefd [open project.tr w]
set namtrace [open simwrls.nam w]

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]

$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)



# configure the nodes
$ns node-config -adhocRouting $val(rp) \
-llType $val(ll) \
-macType $val(mac) \
-ifqType $val(ifq) \
-ifqLen $val(ifqlen) \
-antType $val(ant) \
-propType $val(prop) \
-phyType $val(netif) \
-channelType $val(chan) \
-topoInstance $topo \
-agentTrace ON \
-routerTrace ON \
-macTrace OFF \
-movementTrace ON

for {set i 0} {$i < $val(nn) } { incr i } {
set n($i) [$ns node]
}

# Provide initial location of mobilenodes
$n(0) set X_ 40.0
$n(0) set Y_ 280.0
$n(0) set Z_ 0.0

$n(1) set X_ 80.0
$n(1) set Y_ 300.0
$n(1) set Z_ 0.0

$n(2) set X_ 90.0
$n(2) set Y_ 200.0
$n(2) set Z_ 0.0

$n(3) set X_ 170.0
$n(3) set Y_ 300.0
$n(3) set Z_ 0.0

$n(4) set X_ 200.0
$n(4) set Y_ 200.0
$n(4) set Z_ 0.0

$n(5) set X_ 260.0
$n(5) set Y_ 300.0
$n(5) set Z_ 0.0



# Set a TCP connection between n(1) and n(31)
set tcp [new Agent/TCP/Newreno]
$tcp set class_ 2
$tcp set packetSize_ 1000
set sink [new Agent/TCPSink]
$ns attach-agent $n(2) $tcp
$ns attach-agent $n(3) $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 10.0 "$ftp start"
$ns at 125.0 "$ftp stop"


set tcp2 [new Agent/TCP/Newreno]
$tcp2 set class_ 2
$tcp2 set packetSize_ 600
set sink2 [new Agent/TCPSink]
$ns attach-agent $n(1) $tcp2
$ns attach-agent $n(4) $sink2
$ns connect $tcp2 $sink2
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2
$ns at 50.0 "$ftp2 start"


#defining heads
$ns at 0.0 "$n(0) label CH"
$ns at 0.0 "$n(1) label Source2"
$ns at 0.0 "$n(2) label Source1"
$ns at 0.0 "$n(4) label Destination2"
$ns at 0.0 "$n(3) label Destination1"



$ns at 100.0 "$n(5) setdest 385.0 228.0 5.0"
$ns at 60.0 "$n(2) setdest 200.0 20.0 5.0"
$ns at 30.0 "$n(3) setdest 115.0 85.0 5.0"
$ns at 45.0 "$n(1) setdest 375.0 80.0 5.0"
$ns at 89.0 "$n(4) setdest 167.0 351.0 5.0"
$ns at 78.0 "$n(0) setdest 50.0 359.0 5.0"

#Color change while moving from one group to another
$ns at 73.0 "$n(2) delete-mark N2"
$ns at 73.0 "$n(2) add-mark N2 pink circle"
$ns at 124.0 "$n(3) delete-mark N11"
$ns at 124.0 "$n(3) add-mark N11 purple circle"
$ns at 87.0 "$n(4) delete-mark N26"
$ns at 87.0 "$n(4) add-mark N26 yellow circle"
$ns at 92.0 "$n(1) delete-mark N14"
$ns at 92.0 "$n(1) add-mark N14 green circle"

# Define node initial position in nam
for {set i 0} {$i < $val(nn)} { incr i } {
# 20 defines the node size for nam
$ns initial_node_pos $n($i) 20
}

# Telling nodes when the simulation ends
for {set i 0} {$i < $val(nn) } { incr i } {
$ns at $val(stop) "$n($i) reset";
}

# ending nam and the simulation
$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
$ns at $val(stop) "stop"
$ns at 150.01 "puts \"end simulation\" ; $ns halt"
proc stop {} {
global ns tracefd namtrace
$ns flush-trace
close $tracefd
close $namtrace
exec nam simwrls.nam &
}

$ns run 

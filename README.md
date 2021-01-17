# ECE385-Final-Project

<strong>You are not allowed to copy anything from this repository without explicit citing, especially if you are a ZJUI of UIUC student who is taking this course.</strong>

<h3>FPGA based Game Design: Fruit Ninja</h3>
<ul>
    <li>Advisor: <a href="http://person.zju.edu.cn/en/lichushan" target="_blank">Chushan Li</a>, ZJU-UIUC Institute</li>
    <li>Co-worker: <a href="https://github.com/Xiwei-Wang" target="_blank">Xiwei Wang</a></li>
    <li>It is the final project of UIUC course ECE385: Digital System Laboratory. The game is designed and implemented using System Verilog on FPGA.</li>
    <li>The game has two mouse (one USB mouse and one PS2 mouse) as inputs and VGA display as outputs. The game supports both single-player mode and double-player mode. The video display of the motion of the fruits to be cut on the monitor and the mouse serves as "knife" to cut the fruit when colliding with the fruits</li>
    <li>Features:
        <ul>
            <li>
                Correct interface with SRAM, Flash, USB mouse, PS2 mouse and VGA devices.
            </li>
            <li>
                Correct and smooth movements of the fruits in a parabolic curve with central rotations (via rotational matrices).
            </li>
            <li>
                Correct detection of the cutting process (collision between the mouse and the fruits).
            </li>
            <li>
                Random generation (accurately speaking, pseudo-random) of motion parameters of incoming fruits.
            </li>
            <li>
                Correct double player mode.
            </li>
        </ul>
    </li>
</ul>

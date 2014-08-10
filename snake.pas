(*****************************************************************************
The MIT License (MIT)

Copyright (c) 2014 frin (contact: https://github.com/frin)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*****************************************************************************)
program snake;

uses crt,math;
var i,j,len,bombx,bomby,l,dir,dirnew:byte;
	body:array[1..255,1..2] of byte;
	d:smallint;
	k:char;
	score:integer;

procedure drawbox(x,y,width,height:integer;title:string);
var i1,i2:integer;
begin
	for i2:=1 to height do
	begin
		gotoxy(x,y+i2-1);
		for i1:=1 to width do
		begin
			if (i1 > 1) and (i1 < width) and (i2 > 1) and (i2 < height) then
				write(' ')
			else
				write('M');
		end;
	end;
	if (title <> '') then
	begin
		i1 := y+floor((height-1)/2);
		i2 := x+floor(width/2-length(title)/2);
		gotoxy(i2,i1);
		write(title);
	end;
end;

procedure drawsnake;
var tmp:integer;
begin
	for tmp:=1 to len do
	begin
		gotoxy(body[tmp,1], body[tmp,2]);
		if (tmp = 1) then write('o')
		else write('x');
	end;
end;

function collision:boolean;
var tmp:integer;
begin
	collision := false;
	for tmp:=1 to len do
	begin
		if (body[tmp,1] < 2) or (body[tmp,1] >= 80) then
		begin
			collision:=true;
			break;
		end;
		if (body[tmp,2] < 4) or (body[tmp,2] >= 24) then
		begin
			collision:=true;
			break;
		end;
	end;
end;

procedure death;
begin
	textcolor(lightblue);
	drawbox(1,11,80,3,'');
	gotoxy(37,12);
	textcolor(lightred);
	write('You died!');
	textcolor(lightgray);
	gotoxy(1,25);
	halt;
end;

procedure extend(x,y:integer);
begin
	inc(score,len);
	inc(len);
	body[len,1] := x;
	body[len,2] := y;
	gotoxy(x,y);
	write('x');
	gotoxy(2,2);
	textcolor(white);
	write(score);
	textcolor(lightred);
end;

function snake_contains(x,y:integer):boolean;
var tmp:integer;
begin
	snake_contains := false;
	for tmp:=1 to len do
	begin
		if (body[tmp,1] = x) and (body[tmp,2] = y) then snake_contains := true;
	end;
end;

procedure generate_new;
var x,y:integer;
begin
	repeat
		x := random(78)+1;
		y := random(19)+4;
	until not snake_contains(x,y);
	bombx := x;
	bomby := y;
	gotoxy(x,y);
	inc(l);
	textcolor(lightgreen);
	write(chr(l));
	textcolor(lightred);
end;

procedure movesnake;
var x,y,wasx,wasy,tmp:integer;
	died:boolean;
begin
	case dir of
		1: begin x :=  1; y := 0; end;
		2: begin x :=  0; y := 1; end;
		3: begin x := -1; y := 0; end;
		4: begin x :=  0; y :=-1; end;
	end;
	gotoxy(body[1,1], body[1,2]); write('x');
	gotoxy(body[len,1], body[len,2]); write(' ');
	wasx:=body[len,1];
	wasy:=body[len,2];
	died := false;
	if (snake_contains(body[1,1] + x, body[1,2] + y)) then
		died := true;
	for tmp:=2 to len do
	begin
		body[len-tmp+2,1] := body[len-tmp+1,1];
		body[len-tmp+2,2] := body[len-tmp+1,2];
	end;
	body[1,1] := body[1,1] + x;
	body[1,2] := body[1,2] + y;
	gotoxy(body[1,1], body[1,2]); write('o');
	if (died) then death;
	if (snake_contains(bombx,bomby)) then
	begin
		extend(wasx,wasy);
		generate_new;
	end;
	if (collision) then death;
end;

begin
	clrscr;
	randomize;
	len:=1; d:=200; l:=64; score:=0;
	dir:=1; {1=east,2=south;3=west,4=north}
	for i:=1 to 255 do
		for j:=1 to 2 do
			body[i,j] := 0;
	body[1,1] := 2;
	body[1,2] := 12;
	textcolor(lightblue);
	drawbox(1,1,80,24,'');
	drawbox(1,1,80,3,'Snake game by frin \o/ (c) 2014');
	textcolor(lightred);
	generate_new;
	drawsnake;
	gotoxy(2,2);
	repeat
		delay(d);
		if (keypressed) then
		begin
			k:=readkey;
			if (k = #0) then
			begin
				k:=readkey;
				case k of
					#77: dirnew := 1;
					#80: dirnew := 2;
					#75: dirnew := 3;
					#72: dirnew := 4;
				end;
				if (dir = 1) and (dirnew <> 3) then dir := dirnew;
				if (dir = 2) and (dirnew <> 4) then dir := dirnew;
				if (dir = 3) and (dirnew <> 1) then dir := dirnew;
				if (dir = 4) and (dirnew <> 2) then dir := dirnew;
			end;
			if (k = #27) then death;
		end;
		movesnake;
		gotoxy(2,2);
	until false;
	textcolor(lightgray);
	gotoxy(1,25);
end.
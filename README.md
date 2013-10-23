### Generate Bills from Apples Financial Reports
Apple generates financial reports in txt format. The German tax office wants to see the bills. This script helps to generate the bills from the financial reports.

### What you need
You need pdflatex on your machine. And you should be able to edit LaTeX files because you have to add your address in the head.tex file.

### How it works
For every month generate a dictionary. Let's say you want to generate the bills for December 2012. You could do this:

```
$ cd ~/Documents
$ mkdir financial_reports; cd financial_reports
$ mkdir 1212; cd 1212
```

Download all financial reports from iTunes Connect for that month into that directory.

Copy and past the exchange rates from "Payments & Financial Reports > Payments" within your iTunes Connect and put it into a file called factors.txt. Put that file into the directory with the reports (1212/ in the example). It should look like this:

```
AUD      0.00    13.97   13.97   0.00    0.00    0.00    13.97   0.77022         10.76  EUR
CHF      0.00    33.15   33.15   0.00    0.00    0.00    33.15   0.80030         26.53  EUR
DKK      0.00    23.73   23.73   0.00    0.00    0.00    23.73   0.13359         3.17   EUR
EUR      0.00    247.84  247.84  0.00    0.00    0.00    247.84  1.00000         247.84 EUR
GBP      0.00    4.55    4.55    0.00    0.00    0.00    4.55    1.16484         5.30   EUR
INR      0.00    77.00   77.00   0.00    0.00    0.00    77.00   0.01351         1.04   EUR
JPY      0       179     179     -37     0       0       142     0.00817         1.16   EUR
MXN      0.00    18.20   18.20   0.00    0.00    0.00    18.20   0.05824         1.06   EUR
NOK      0.00    7.84    7.84    0.00    0.00    0.00    7.84    0.13393         1.05   EUR
NZD      0.00    1.81    1.81    0.00    0.00    0.00    1.81    0.61326         1.11   EUR
RUB      0.00    138.60  138.60  0.00    0.00    0.00    138.60  0.02395         3.32   EUR
SEK      0.00    4.26    4.26    0.00    0.00    0.00    4.26    0.11502         0.49   EUR
SGD      0.00    1.81    1.81    0.00    0.00    0.00    1.81    0.60221         1.09   EUR
USD      0.00    58.10   58.10   0.00    0.00    0.00    58.10   0.74200         43.11  EUR
ZAR      0.00    11.19   11.19   0.00    0.00    0.00    11.19   0.08311         0.93   EUR
```

Set your address in head.tex: Open head.tex with your favorite text editor and search for Mustermann. Change the template address. Then do:

```
$ cd ~/Documents/financial_reports
$ perl summarize.pl 1212 head.tex tail.tex
```

Now you should have files called bill_1212.pdf and bill_1212.tex in that directory. 

Done.

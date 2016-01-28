#!/usr/bin/perl -w

use strict;

#print "$ARGV[0]\n";

if (not defined($ARGV[0])) {
  die "usage: $0 <dirname> <tex-head> <tex-tail>\n";
}

open(HEAD, $ARGV[1]) || die "could not open head file: $!\n";
open(TAIL, $ARGV[2]) || die "could not open tail file: $!\n";
my $outputname = "bill_$ARGV[0].tex";
open(OUT, ">$outputname") || die "could not open output file: $!\n";

while (defined(my $line = <HEAD>)) {
  print OUT $line;
}

# fetch the exchange factors from factors.txt
my $factor_file_name = $ARGV[0] . "/factors.txt";
open(FACTORS, $factor_file_name) || die "could not open factors file: $!\n";
my %exchange_factor;
my %withholding_tax_factor;
while (defined(my $line = <FACTORS>)) {
#  print "$line\n";
  my @line_components = split(/\t/,$line);
  s{^\s+|\s+$}{}g foreach @line_components;
#  print "$line_components[3]\n";
  #     print "-$line_components[0]- -$line_components[8]- \n";
  #    print "$line_components[4] $line_components[3]\n";
  $exchange_factor{$line_components[0]} = $line_components[8];
  $withholding_tax_factor{$line_components[0]} = 1.0-abs($line_components[4]/$line_components[3]);
}
close (FACTORS);

my $filecount = 0;
my $total_euro = 0.0;
my %app_name;
my %app_income;
opendir(REPORTSDIR, $ARGV[0]) || die "could not open directory: $!\n";
while (my $name = readdir(REPORTSDIR)) {
  if ($name eq "." || $name eq ".." || $name eq "factors.txt") {
    next;
  }
  print "processing: $name\n";
  
  my $filename = $ARGV[0] . "/" . $name;
  open(FILE, $filename) || die "could not open file: $!\n";
  
  my %amount;
  my %app_id_dict;
  my %currency_dict;
  my %price_dict;
  while (defined(my $line = <FILE>)) {
    my @line_components = split(/\t/,$line);
    my $i = 0;
    if ($line_components[0] eq "Start Date") {
      next;
    }
    foreach my $line_component (@line_components) {
      #print "($i:$line_component) - ";
      $i++;
    }
    if ($i < 10) {
      next;
    }
    if ($filecount < 1) {
      my @date_components_start = split(/\//,$line_components[0]);
      my @date_components_end = split(/\//,$line_components[1]);
      print OUT "Rechnungszeitraum: $date_components_start[1].$date_components_start[0].$date_components_start[2] -
      $date_components_end[1].$date_components_end[0].$date_components_end[2]\\\\\n";
      print OUT "\n";
      #	    print OUT "\\vspace{1cm}\n";
      print OUT "\\begin{longtable}{|c|r|r|c|r|} \\hline\n";
      print OUT "Produkt ID & Preis & St\\\"uckzahl & Umrechnungsfaktor & Gesamtpreis \\\\ \\hline \\hline\n";
    }
    my $common_key = $line_components[10] . " " . $line_components[6] . " " . $line_components[8];
    my $amount_value = $amount{$common_key};
    $amount_value += $line_components[5];
#    print "common_key $common_key amount_value $amount_value\n";
    $amount{$common_key} = $amount_value;
    $filecount++;
    
    $app_name{$line_components[10]} = $line_components[12];
    if (!$app_income{$line_components[10]}) {
      $app_income{$line_components[10]} = 0.0;
    }
    $app_id_dict{$common_key} = $line_components[10];
    $currency_dict{$common_key} = $line_components[8];
    $price_dict{$common_key} = $line_components[6];
  }
  close (FILE);
  
  my @keys = keys %amount;
#  my @amount_values = values %amount;
#  my @app_id_values = values %app_id_dict;
#  my @currency_values = values %currency_dict;
#  my @price_values = values %price_dict;
  while (@keys) {
    my $key = pop(@keys);
#    my $amount = pop(@amount_values);
#    my $app_id = pop(@app_id_values);
#    my $currency = pop(@currency_values);
#    my $price = pop(@price_values);
    my $amount = $amount{$key};
    my $app_id = $app_id_dict{$key};
    my $currency = $currency_dict{$key};
    my $price = $price_dict{$key};
    my $exchange_factor = $exchange_factor{$currency};
    my $withholding_tax_factor = $withholding_tax_factor{$currency};
    my $total_price = $price*$amount*$exchange_factor*$withholding_tax_factor;
    my $app_income = $app_income{$app_id}+$total_price;
    $app_income{$app_id} = $app_income;
    if ($price > 0) {
      print OUT $app_id, " & ", $price, " ", $currency, " & ", $amount,  " & ", $exchange_factor, " & ";
      printf OUT "%.2f EUR \\\\ \\hline \n", $total_price;
      $total_euro += $total_price;
#      print "$app_id $price $currency $amount  $exchange_factor ";
#      printf "%.2f EUR\n", $total_price;
    }
  }
}
printf OUT "\\hline & & & Gesamt & %.2f EUR \\\\ \\hline \n", $total_euro;
printf "\tGesamt %.2f EUR\n\n", $total_euro;

my @keys = keys %app_income;
while(@keys) {
  my $key = pop(@keys);
  printf "\t%.2f EUR \t", $app_income{$key};
  print $app_name{$key}, "\n";
}

while (defined(my $line = <TAIL>)) {
  print OUT $line;
}
close(OUT);
close(HEAD);
close(TAIL);
closedir(REPORTSDIR);

`pdflatex $outputname`;
`pdflatex $outputname`;
`rm *.aux *.log`;
<?php

// Set current directory
$cd = dirname(__FILE__);

// Creating temp file
$url = file_get_contents('http://www.bartleby.com/titles/');
file_put_contents($cd.'/temp.html', $url);

// Cleaning temp file for not well-formed content
$contents = file($cd.'/temp.html');
$out=[];
$i = 1;
foreach($contents as $line){    
    if($i>=165 && $i<=1008 && strpos($line,'var vclk_options') != true) {        
        $out[] = str_replace('E.C. Stedman</A>', 'E.C. Stedman', $line) ;
    }    
    $i++;
}     
file_put_contents($cd.'/temp.html', $out);

// Reading in temp file for parsing
$html = new DOMDocument('1.0', 'UTF-8');
$html->loadHTMLFile($cd.'/temp.html');
$xpath = new DOMXPath($html);

// Extract web data into array
$i = 1;
$works = [];
$table = $xpath->query('//tr/*');

foreach ($table as $t) {
    $works['title'][$i] = "";
    $xpathstr = '//tr['.$i.']/td/a[1]';
    $node = $xpath->query($xpathstr);
    
    foreach ($node as $n) {        
        $works['title'][$i] = $n->nodeValue;
    }
    
    $works['author'][$i] = "";
    $xpathstr = '//tr['.$i.']/td/a[2]';
    $node = $xpath->query($xpathstr);
    
    foreach ($node as $n) {        
        $works['author'][$i] = $n->nodeValue;        
    }
    $i++;
}

// Output to CSV
$fp = fopen($cd.'/HTMLDATA_php.csv', 'w');
fputcsv($fp, array('Title', 'Author'));

for ($row = 1; $row <= sizeof($works['title']); $row++) {
    if (strlen($works['title'][$row]) > 0) {
        fputcsv($fp, array($works['title'][$row], $works['author'][$row]));
    }
}

// Remove temp file
if (file_exists($cd.'/temp.html')) {  unlink($cd.'/temp.html'); }

echo "Successfully HTML data to CSV file!";

?>
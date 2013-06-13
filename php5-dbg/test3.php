<?php
  class Human {
    public $name;
    public $height;
    public $weight;
    function show() {
      echo "<tr><td>$this->name</td><td>$this->height</td><td>$this->weight</td></tr>";
    }
  }

  session_start();
  $man = new Human();
  $man->name = htmlspecialchars($_POST['name']);
  $man->height = htmlspecialchars($_POST['height']);
  $man->weight = htmlspecialchars($_POST['weight']);
  $_SESSION[$man->name] = $man;
?>
<table border="1">
<tr><th>名前</th><th>身長</th><th>体重</th></tr>
<?php
  foreach ($_SESSION as $s) {
    $s->show();
  }
?>
</table>
<a href="object2.html">戻る</a>

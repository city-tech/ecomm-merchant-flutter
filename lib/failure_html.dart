class FailureHtml {
  static const String content = '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Transaction Failed</title>
  <style>
    body {
      font-family: Arial, Helvetica, sans-serif;
      background-color: #f2f2f2;
    }

    .container {
      margin: 50px auto;
      width: 80%;
      max-width: 600px;
      background-color: #fff;
      border-radius: 5px;
      box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.2);
      padding: 30px;
    }

    h1 {
      text-align: center;
      color: #af4c4c;
      margin-bottom: 30px;
    }

    p {
      font-size: 18px;
      margin-bottom: 20px;
    }

    .btn {
      display: inline-block;
      background-color: #af4c4c;
      color: #fff;
      padding: 10px 20px;
      text-align: center;
      text-decoration: none;
      border-radius: 5px;
      transition: background-color 0.3s;
    }

    .btn:hover {
      background-color: #993939;
    }
  </style>
</head>

<body>
<div class="container">
  <h1>Transaction Failed!</h1>
  <p>Sorry, your transaction failed. Please try again.</p>
  <a id="btn" class="btn">
    Try Again
  </a>
</div>
</body>
</html>
  ''';
}

class SuccessHtml {
  static const String content = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Success</title>
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

            padding: 30px;
        }

        h1 {
            text-align: center;
            color: #4CAF50;
            margin-bottom: 30px;
        }

        p {
            font-size: 18px;
            margin-bottom: 20px;
        }

        .btn {
            display: inline-block;
            background-color: #4CAF50;
            color: #fff;
            padding: 10px 20px;
            text-align: center;
            text-decoration: none;
            border-radius: 5px;
            transition: background-color 0.3s;
        }

        .btn:hover {
            background-color: #3e8e41;
        }
        .slide-up {
            transform: translateY(100%);
            animation: slide-up 0.5s ease-in-out forwards;
        }

        @keyframes slide-up {
            to {
                transform: translateY(0);
            }
        }
        .fade-in {
            opacity: 0;
            animation: fade-in 1s ease-in forwards;
        }
        @keyframes fade-in {
            to {
                opacity: 1;
            }
        }

    </style>
</head>

<body>
    <script>

        try {
            if (window !== window.top) {
                if (window.origin === window.top.origin) {
                    window.top.location.href = window.location.href;
                } else {
                    document.getElementById('btn').textContent = 'Click to Complete';
                    document.getElementById('btn').style.display = 'block';
                }
            }
        } catch (e) {
            console.log(window.origin)
            console.log(window.top.origin)
            console.log('Navigation blocked by browser policy' + e);
        }
    </script>
<div class="container slide-up">
    <div style="display: flex;align-items: center;justify-content: center" >
        <img src="Animation%20-%201727085620169.gif">
    </div>

    <h1>Transaction Successful!</h1>
   
</div>
<script>
    // Get the token from URL
    const url = window.location.href;
    const urlParams = new URLSearchParams(url.split("?")[1]);
    const token = urlParams.get("token");
    console.log("Token info: " + token);

    // Handle button click
    const btn = document.getElementById("btn");
    btn.addEventListener("click", () => {
        window.Toaster.postMessage("success");
    });
</script>
</body>
</html>
''';
}

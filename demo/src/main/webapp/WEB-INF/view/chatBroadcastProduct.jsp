<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<title>Web socket STOMP SockJS Example</title>
	<!-- jQuery -->
	<script src="https://code.jquery.com/jquery-3.5.1.js"></script>
	<link rel="stylesheet" href="/resources/css/chatBroadcastProduct.css">
	

</head>
<body>
	<div class="container">
		<div class="title_text">
			<h2>${pr_title}</h2>
		</div>
		<div class="row">
			<div class="col_6">
				<div class="row_3">
				<!-- 
					<div class="input_group">
						
						<div class="btn_group">
							<button type="button" id="connect" class="btn btn-sm btn-outline-secondary" onclick="connect()">connect</button>
							<button type="button" id="disconnect" class="btn btn-sm btn-outline-secondary" onclick="disconnect()" disabled>disconnect</button>
						</div>
						 
					</div>
				 -->				
				</div>				
				<div class="col_6">
					<div id="content">
						<div id="content">
							<c:forEach var="chatRoom" items="${chatHistory}">
								<p>
									<span id="chatRoomSenderName">${chatRoom.senderName}</span><br>
									<span id="chatRoomContent">${chatRoom.content}</span><br>
									<span id="chatRoomSendTime">${chatRoom.sendTime}</span><br>
								</p>	
							</c:forEach>
						</div>
					</div>
					<!-- 
					<div>
						<span class="float-right">
							<button id="clear" class="btn btn-primary" onclick="clearBroadcast()" style="display: none;">Clear</button>				
						</span>
					</div>
					-->
				</div>
				<div class="row_3">
					<div class="input_group" id="sendMessage">
						<input type="text" placeholder="Message" id="message" class="form_control"/>
						<div class="input_group_append">
							<button id="send" class="btn btn-primary" onclick="send()">보내기</button>
							<input type="hidden" value="${login.getNickName()}" id="buyerName"/>
							<input type="hidden" value="${login.getEmail()}" id="buyerId"/>
							<input type="hidden" value="${pr_id}" id="pr_id"/>
							<input type="hidden" value="${sellerId}" id="sellerId"/>
							<input type="hidden" value="${sellerName}" id="sellerName"/>						
							<input type="hidden" value="${id}" id="id"/>						
						</div>					
					</div>				
				</div>
			</div>
		</div>
	</div>
	
	
	<script src="/webjars/stomp-websocket/2.3.3-1/stomp.js" type="text/javascript"></script>
	<script src="/webjars/sockjs-client/1.1.2/sockjs.js" type="text/javascript"></script>
	
	<script type="text/javascript">
	
		var stompClient = null;
		var buyerName = $('#buyerName').val();
		var buyerId = $('#buyerId').val();
		var pr_id = $('#pr_id').val();
		var sellerName = $('#sellerName').val();
		var sellerId = $('#sellerId').val();	
		var senderName = $('#buyerName').val();
		var id = $('#id').val();
		
		
/*		function setConnected(connected) {		
			$('#connect').prop('disabled', connected);
			$('#disconnect').prop('disabled', !connected);
			if (connected) {
				$('#sendMessage').show();
			} else {
				$('#sendMessage').hide();				
			}
		};
*/
		$(document).ready(connect());
		
		function connect() {
			var socket = new SockJS('/broadcast');
			var url = '/user/' + id + '/queue/messages';
			stompClient = Stomp.over(socket);
			
			stompClient.connect({}, function() {
				stompClient.subscribe(url, function(output) {
					console.log("broadcastMessage working");
					showBroadcastMessage(createTextNode(JSON.parse(output.body)));
				});
						//setConnected(true);				
				}, 
						function (err) {
							alert('error' + err);
			});

		};
		
		function sendBroadcast(json) {
			
			stompClient.send("/app/broadcast", {}, JSON.stringify(json));
		}
		
		function send() {
			var content = $('#message').val();
			sendBroadcast({
				'id': id,
				'buyerName': buyerName, 'content': content,
				'sellerName': sellerName,
				'buyerId': buyerId, 'sellerId': sellerId,
				'pr_id': pr_id,
				'senderName': senderName
				});
			$('#message').val("");
		}
		
		var inputMessage = document.getElementById('message'); 
		inputMessage.addEventListener('keyup', function enterSend(event) {
			
			if (event.keyCode === null) {
				event.preventDefault();
			}
			
			if (event.keyCode === 13) {
				send();
			}
		});
		
		function createTextNode(messageObj) {
			console.log("createTextNode");
			console.log("messageObj: " + messageObj.content);
            return '<p><div class="row alert alert-info"><div class="col_8">' +
            messageObj.senderName +
            '</div><div class="col_4 text-right">' +
            messageObj.content+
            '</div><div>[' +
            messageObj.sendTime +
            ']</div></p>';
        }
		
		function showBroadcastMessage(message) {
            $("#content").html($("#content").html() + message);
        }
		
		function clearBroadcast() {
			$('#content').html("");
		}
		
		function ajaxChatRoom() {
			
			$.ajax({
				url:'/addChatRoom/ajax',
				type: 'POST',
				data: JSON.stringify({
					id: id,
					pr_id: pr_id,
					buyerId: buyerId,
					sellerId: sellerId,
					buyerName: buyerName,
					sellerName: sellerName
				}),
				dataType: 'json',
				//magic setting resolved an error
				contentType: 'application/json',
				complete: function(data) {
					console.log('jQuery ajax from submit complete');
				}
			});
		}
	
	</script>
</body>
</html>
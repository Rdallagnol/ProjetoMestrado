<%@include file="../template/header.jsp" %>
<div style="border: 0.5px solid silver">
        <c:forEach items="${mensagem}" var="linha">
            ${linha}<br>
        </c:forEach>
        <img src="${pageContext.servletContext.contextPath}/file/plot .png">
        <img src="${pageContext.servletContext.contextPath}/file/boxplot .png">
        <img src="${pageContext.servletContext.contextPath}/file/post-plot .png">
        <img src="${pageContext.servletContext.contextPath}/file/variogram .png">
           
</div>
 
      
<%@include file="../template/footer.jsp" %>





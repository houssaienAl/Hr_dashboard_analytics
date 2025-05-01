import React, { useState } from 'react';
import './styles/Layout.css';
import { Link, useLocation } from 'react-router-dom';


interface LayoutProps {
  children: React.ReactNode;
}

const Layout: React.FC<LayoutProps> = ({ children }) => {
  const [isDropdownOpen, setDropdownOpen] = useState(false);
  const location = useLocation();

  const toggleDropdown = () => {
    setDropdownOpen(!isDropdownOpen);
  };

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="logo">
          <img src="/logo.png" alt="Logo" />
        </div>
        <nav className="menu">
        <Link to="/home" className={location.pathname === '/home' ? 'active' : ''}>
  <i className="fas fa-home"></i>
</Link>

          <a href="#"><i className="fas fa-chart-line"></i></a>
          <Link to="/Employee" className={location.pathname === '/Employee' ? 'active' : ''}>
  <i className="fas fa-user"></i>
</Link>

          <a href="#"><i className="fas fa-file-pdf"></i></a>
        </nav>
        <div className="bottom-menu">
          <a href="#"><i className="fas fa-cog"></i></a>
          <a href="#"><i className="fas fa-question-circle"></i></a>
        </div>
      </aside>

      <div className="main">
        <header className="navbar">
          <div className="menu-toggle">
            <i className="fas fa-bars"></i>
          </div>
          <div className="nav-icons">
            <i className="fas fa-bell"></i>
            <div className="user-menu">
              <i className="fas fa-user-circle" onClick={toggleDropdown}></i>
              {isDropdownOpen && (
                <div className="dropdown-menu">
                  <div className="dropdown-header">My Account</div>
                  <Link to="/AccountSettings" className="dropdown-item">
                    <i className="fas fa-user"></i> Account Settings
                </Link>
                  <a href="#" className="dropdown-item">
                    <i className="fas fa-sign-out-alt"></i> Logout
                  </a>
                </div>
              )}
            </div>
          </div>
        </header>

        <main className="content">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;
